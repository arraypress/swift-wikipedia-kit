//
//  WikipediaKit+Pages.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  More about one article: suggestions for its title, its Wikidata item, its
//  readership, its media and its categories.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension WikipediaKit {

    /// Article titles that start with what has been typed — the API made for
    /// autocomplete, faster than ``searchTitles(_:language:limit:)``, which runs
    /// a full-text search.
    ///
    /// ```swift
    /// try await WikipediaKit.suggestions("alan tur")   // ["Alan Turing", "Alan Turing Institute", …]
    /// ```
    ///
    /// - Parameters:
    ///   - prefix: What has been typed
    ///   - limit: At most this many, 1–100 (default 10)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: Titles, best first; empty when nothing matches
    /// - Throws: ``WikipediaError/invalidQuery(_:)`` for an empty prefix
    static func suggestions(
        _ prefix: String,
        limit: Int = 10,
        language: WikipediaLanguage = .english
    ) async throws -> [String] {
        try Validation.searchQuery(prefix)
        let data = try await performRequest(url: WikipediaURLs.suggestions(prefix: prefix, limit: max(1, min(100, limit)), language: language))
        // ["the prefix", [titles], [descriptions], [urls]]
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [Any], root.count > 1 else {
            throw WikipediaError.parseError("the suggestions response is not the expected array")
        }
        return root[1] as? [String] ?? []
    }

    /// The article's Wikidata item ID, e.g. `Q7251` for Alan Turing — the key to
    /// its structured facts (see swift-wikidata).
    ///
    /// - Returns: The ID; `nil` when the article has none or does not exist
    /// - Throws: ``WikipediaError`` on a bad title or a failed request
    static func wikidataID(
        for title: String,
        language: WikipediaLanguage = .english
    ) async throws -> String? {
        try Validation.articleTitle(title)
        guard let pages = try queryPages(try await performRequest(url: WikipediaURLs.wikidataItem(title: title, language: language))) else { return nil }
        for (key, value) in pages where key != "-1" {
            if let item = ((value as? [String: Any])?["pageprops"] as? [String: Any])?["wikibase_item"] as? String { return item }
        }
        return nil
    }

    /// How many people read an article each day (crawlers excluded, all platforms).
    ///
    /// ```swift
    /// let lastWeek = try await WikipediaKit.pageViews("Alan Turing", from: weekAgo, to: Date())
    /// ```
    ///
    /// Days are UTC, as Wikimedia counts them; figures start in July 2015 and
    /// usually lag by a day.
    ///
    /// - Parameters:
    ///   - title: The article
    ///   - start: First day
    ///   - end: Last day (default: today)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: One entry a day, oldest first; empty when there are no figures
    ///   for the range or the article
    /// - Throws: ``WikipediaError/invalidQuery(_:)`` for a range that runs backwards
    static func pageViews(
        _ title: String,
        from start: Date,
        to end: Date = Date(),
        language: WikipediaLanguage = .english
    ) async throws -> [WikipediaDailyViews] {
        try Validation.articleTitle(title)
        try Validation.dateRange(from: start, to: end)
        do {
            let data = try await performRequest(url: WikipediaURLs.pageViews(title: title, from: start, to: end, language: language))
            return try ResponseDecoding.decode(WikipediaPageViewsResponse.self, from: data).items
                .compactMap { item in WikipediaFormat.pageViewsDate(item.timestamp).map { WikipediaDailyViews(date: $0, views: item.views) } }
                .sorted { $0.date < $1.date }
        } catch WikipediaError.networkError(let message) where message.hasPrefix("404") {
            return []   // no figures: an unknown article, or a range with no data
        }
    }

    /// The images, video and sound an article uses, in page order.
    ///
    /// - Returns: The media; empty for an article without any or one that does not exist
    /// - Throws: ``WikipediaError`` on a bad title or a failed request
    static func media(
        of title: String,
        language: WikipediaLanguage = .english
    ) async throws -> [WikipediaMediaItem] {
        try Validation.articleTitle(title)
        do {
            let data = try await performRequest(url: WikipediaURLs.media(title: title, language: language))
            return try ResponseDecoding.decode(WikipediaMediaListResponse.self, from: data).items.map(WikipediaMediaItem.init(response:))
        } catch WikipediaError.networkError(let message) where message.hasPrefix("404") {
            return []
        }
    }

    /// The article's visible categories, without their namespace prefix —
    /// "1912 births", not "Category:1912 births". Hidden maintenance categories
    /// are left out.
    ///
    /// - Returns: The categories, sorted; empty for an article without any or
    ///   one that does not exist
    /// - Throws: ``WikipediaError`` on a bad title or a failed request
    static func categories(
        of title: String,
        language: WikipediaLanguage = .english
    ) async throws -> [String] {
        try Validation.articleTitle(title)
        var names: [String] = [], cursor: String?
        // The API pages its answer; follow it, but not forever.
        for _ in 0..<10 {
            let data = try await performRequest(url: WikipediaURLs.categories(title: title, cursor: cursor, language: language))
            guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw WikipediaError.parseError("the categories response is not a JSON object")
            }
            let pages = (root["query"] as? [String: Any])?["pages"] as? [String: Any] ?? [:]
            for (key, value) in pages where key != "-1" {
                let entries = (value as? [String: Any])?["categories"] as? [[String: Any]] ?? []
                names += entries.compactMap { ($0["title"] as? String).map(WikipediaFormat.categoryName) }
            }
            guard let next = (root["continue"] as? [String: Any])?["clcontinue"] as? String else { break }
            cursor = next
        }
        return Array(Set(names)).sorted()
    }
}
