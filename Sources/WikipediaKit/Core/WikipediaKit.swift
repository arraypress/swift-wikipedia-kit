//
//  WikipediaKit.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Wikipedia, keyless: search, summaries, full text and the other languages an
//  article exists in, from the public search and REST APIs. The URLs are built
//  in Support/WikipediaURLs, the text cleaned in Support/WikipediaText, and the
//  responses mapped by Extensions/WikipediaArticle+Summary — this file is the
//  public surface and the one network call.
//

import Foundation
// On Linux and Windows, URLSession and URLRequest live in FoundationNetworking.
// Apple platforms are the ones supported; this only lets the package build
// elsewhere (reported from Windows in issue #1).
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A lightweight Wikipedia query library for Apple platforms.
///
/// ```swift
/// import WikipediaKit
///
/// let results = try await WikipediaKit.search("quantum physics")
/// let article = try await WikipediaKit.getArticle("Swift (programming language)")
/// let random = try await WikipediaKit.randomArticle()
/// let text = try await WikipediaKit.getContent("Alan Turing")?.text
/// ```
///
/// No API key. Every request carries a User-Agent with a contact URL, as
/// Wikimedia's policy asks; for high volume, add caching or rate limiting.
public struct WikipediaKit {

    /// The User-Agent every request carries. Wikimedia's policy asks for a way
    /// to reach the client's author; a request without one can be blocked (403).
    static let userAgent = "WikipediaKit/2.0 (https://github.com/arraypress/swift-wikipedia-kit)"

    // MARK: - Search

    /// Search Wikipedia for articles matching the given query.
    ///
    /// ```swift
    /// let results = try await WikipediaKit.search("machine learning", limit: 5)
    /// for result in results {
    ///     print("\(result.title): \(result.snippet)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - query: Search terms to find articles for
    ///   - language: Wikipedia language edition (default: English)
    ///   - limit: Maximum number of results to return (1-50, default: 10)
    /// - Returns: Search results in Wikipedia's order, each with a relevance score
    /// - Throws: `WikipediaError` if the search fails or query is invalid
    public static func search(
        _ query: String,
        language: WikipediaLanguage = .english,
        limit: Int = 10
    ) async throws -> [WikipediaSearchResult] {
        try Validation.searchQuery(query)
        let data = try await performRequest(url: WikipediaURLs.search(query: query, language: language, limit: max(1, min(50, limit))))
        return try ResponseDecoding.decode(WikipediaSearchResponse.self, from: data).query.search.map { result in
            WikipediaSearchResult(
                title: result.title,
                snippet: WikipediaText.clean(result.snippet),
                pageId: result.pageid,
                wordCount: result.wordcount,
                relevanceScore: WikipediaText.relevance(query: query, title: result.title, snippet: result.snippet)
            )
        }
    }

    /// Quick search that returns only article titles — for autocomplete.
    ///
    /// ```swift
    /// let titles = try await WikipediaKit.searchTitles("Nobel Prize", limit: 5)
    /// ```
    ///
    /// - Parameters:
    ///   - query: Search terms
    ///   - language: Wikipedia language edition (default: English)
    ///   - limit: Maximum number of titles (default: 10)
    /// - Returns: Array of article titles
    /// - Throws: `WikipediaError` if the search fails
    public static func searchTitles(
        _ query: String,
        language: WikipediaLanguage = .english,
        limit: Int = 10
    ) async throws -> [String] {
        try await search(query, language: language, limit: limit).map(\.title)
    }

    // MARK: - Articles

    /// A Wikipedia article's summary: lead, description, thumbnail and page.
    ///
    /// ```swift
    /// if let article = try await WikipediaKit.getArticle("Artificial Intelligence") {
    ///     print("\(article.title): \(article.extract)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: Exact or approximate article title
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: Article summary or `nil` if not found
    /// - Throws: `WikipediaError` for network or parsing errors
    public static func getArticle(
        _ title: String,
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle? {
        try Validation.articleTitle(title)
        do {
            let data = try await performRequest(url: WikipediaURLs.summary(title: title, language: language))
            return WikipediaArticle(summary: try ResponseDecoding.decode(WikipediaSummaryResponse.self, from: data), language: language)
        } catch WikipediaError.networkError(let message) where message.hasPrefix("404") {
            return nil
        }
    }

    /// A random article — each call a different one.
    ///
    /// - Parameter language: Wikipedia language edition (default: English)
    /// - Returns: A random Wikipedia article summary
    /// - Throws: `WikipediaError` if the request fails
    public static func randomArticle(
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle {
        let data = try await performRequest(url: WikipediaURLs.random(language: language))
        return WikipediaArticle(summary: try ResponseDecoding.decode(WikipediaSummaryResponse.self, from: data), language: language)
    }

    /// Wikipedia's featured article for a day, chosen daily by its community.
    ///
    /// ```swift
    /// let today = try await WikipediaKit.featuredArticle()
    /// let lastWeek = try await WikipediaKit.featuredArticle(for: Date().addingTimeInterval(-7 * 86_400))
    /// ```
    ///
    /// The date is sent in the Gregorian calendar whatever the device uses — a
    /// Mac on the Buddhist calendar asked for the year 2569 and got a 404.
    ///
    /// - Parameters:
    ///   - date: Date to get featured article for (default: today)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: The featured article for the specified date
    /// - Throws: `WikipediaError` if no featured article exists for the date
    /// - Note: Featured articles are only available for certain language editions
    public static func featuredArticle(
        for date: Date = Date(),
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle {
        let data = try await performRequest(url: WikipediaURLs.featured(date: date, language: language))
        return WikipediaArticle(summary: try ResponseDecoding.decode(WikipediaFeaturedResponse.self, from: data).tfa, language: language)
    }

    /// Search for an article and return the best match: the exact title if
    /// there is one, else the top search result.
    ///
    /// - Parameters:
    ///   - query: Search terms or article title
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: Best matching article or `nil` if none found
    /// - Throws: `WikipediaError` if the search fails
    public static func findArticle(
        _ query: String,
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle? {
        if let exactMatch = try await getArticle(query, language: language) {
            return exactMatch
        }
        guard let firstResult = try await search(query, language: language, limit: 1).first else { return nil }
        return try await getArticle(firstResult.title, language: language)
    }

    // MARK: - Full text and translations

    /// The article's complete plain text.
    ///
    /// A different endpoint from ``getArticle(_:language:)`` on purpose: that
    /// one returns the REST summary, which is the lead paragraph. This is
    /// `action=query&prop=extracts&explaintext`, which is the page. For Alan
    /// Turing that is 448 characters against 63,928, so the two are not
    /// interchangeable and neither should quietly stand in for the other.
    ///
    /// - Throws: ``WikipediaError`` on a bad title or a failed request.
    /// - Returns: `nil` when no such article exists.
    public static func getContent(
        _ title: String,
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaContent? {
        try Validation.articleTitle(title)
        let data = try await performRequest(url: WikipediaURLs.extract(title: title, language: language))
        guard let pages = try queryPages(data) else { return nil }

        // Keyed by page id, and a MISSING page is keyed "-1" with no extract —
        // so the absence has to be read from the shape rather than from an
        // error, which the API does not return for this.
        for (key, value) in pages {
            guard key != "-1", let page = value as? [String: Any],
                  let text = page["extract"] as? String, !text.isEmpty,
                  let pageId = page["pageid"] as? Int,
                  let pageTitle = page["title"] as? String else { continue }
            return WikipediaContent(
                title: pageTitle,
                text: text,
                pageId: pageId,
                language: language,
                url: WikipediaURLs.article(title: pageTitle, languageCode: language.code)
                    ?? URL(string: "https://\(language.code).wikipedia.org")!
            )
        }
        return nil
    }

    /// Every other language this article exists in.
    ///
    /// The titles are carried, not derived: an article's name in another
    /// language is frequently not a translation of this one — `Alan Turing`
    /// is `ألان تورنج` in Arabic — so a code alone cannot build a working URL.
    public static func getTranslations(
        _ title: String,
        language: WikipediaLanguage = .english
    ) async throws -> [WikipediaTranslation] {
        try Validation.articleTitle(title)
        let data = try await performRequest(url: WikipediaURLs.langLinks(title: title, language: language))
        guard let pages = try queryPages(data) else { return [] }

        for (key, value) in pages where key != "-1" {
            guard let page = value as? [String: Any],
                  let links = page["langlinks"] as? [[String: Any]] else { continue }
            return links.compactMap { link in
                // `*` carries the TITLE in that language and `autonym` the
                // language's own name; older responses put the title in `*`
                // alone, so both are read and the autonym falls back to the
                // code rather than to the title.
                guard let code = link["lang"] as? String,
                      let translated = link["*"] as? String ?? link["title"] as? String else { return nil }
                return WikipediaTranslation(code: code, name: link["autonym"] as? String ?? code, title: translated)
            }
            .sorted { $0.code < $1.code }
        }
        return []
    }
}

// MARK: - Request

extension WikipediaKit {

    /// The `query.pages` object of an `action=query` response.
    static func queryPages(_ data: Data) throws -> [String: Any]? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw WikipediaError.parseError("the response is not a JSON object")
        }
        return (root["query"] as? [String: Any])?["pages"] as? [String: Any]
    }

    /// One GET, its status mapped onto ``WikipediaError``.
    static func performRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WikipediaError.networkError("Invalid response type")
            }
            switch httpResponse.statusCode {
            case 200:
                return data
            case 403:
                // Not a rate limit. Wikimedia returns 403 for a blocked or
                // missing User-Agent and for a malformed path; calling it
                // "rate limited" sends the caller off to wait rather than fix
                // the request.
                throw WikipediaError.networkError("403 - Forbidden (check the User-Agent and the request path)")
            case 404:
                throw WikipediaError.networkError("404 - Not found")
            case 429:
                throw WikipediaError.rateLimited
            case 500...599:
                throw WikipediaError.serverError(httpResponse.statusCode)
            default:
                throw WikipediaError.networkError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as WikipediaError {
            throw error
        } catch let error as URLError where error.code == .cannotFindHost || error.code == .dnsLookupFailed {
            // No such Wikipedia: `xx.wikipedia.org` does not resolve.
            throw WikipediaError.invalidLanguage(url.host?.components(separatedBy: ".").first ?? url.absoluteString)
        } catch {
            throw WikipediaError.networkError(error.localizedDescription)
        }
    }
}
