//
//  WikipediaKit+Feed.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  The front page: the daily feed and what happened on a day.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension WikipediaKit {

    /// Wikipedia's front page for a day: featured article, most read, news,
    /// picture of the day, "Did you know…" and anniversaries.
    ///
    /// ```swift
    /// let feed = try await WikipediaKit.dailyFeed()
    /// for trending in feed.mostRead.prefix(5) {
    ///     print("\(trending.rank). \(trending.article.title) — \(trending.views) views")
    /// }
    /// ```
    ///
    /// Sections a language edition does not carry come back empty, and so does
    /// every section for a day with no feed (they begin in 2016). The date is
    /// sent in the Gregorian calendar whatever the device uses.
    ///
    /// - Parameters:
    ///   - date: The day (default: today)
    ///   - language: Wikipedia language edition (default: English)
    /// - Throws: ``WikipediaError`` if the request fails
    static func dailyFeed(
        for date: Date = Date(),
        language: WikipediaLanguage = .english
    ) async throws(WikipediaError) -> WikipediaDailyFeed {
        do {
            let data = try await performRequest(url: WikipediaURLs.dailyFeed(date: date, language: language))
            return WikipediaDailyFeed(response: try ResponseDecoding.decode(WikipediaDailyFeedResponse.self, from: data),
                                      date: date, language: language)
        } catch WikipediaError.networkError(let message) where message.hasPrefix("404") {
            return WikipediaDailyFeed(date: date, featured: nil, mostRead: [], news: [], picture: nil, didYouKnow: [], onThisDay: [])
        }
    }

    /// What happened on a day of the year: events, births, deaths, holidays, or
    /// the editors' selection.
    ///
    /// ```swift
    /// let births = try await WikipediaKit.onThisDay(month: 10, day: 11, type: .births)
    /// ```
    ///
    /// - Parameters:
    ///   - month: 1–12
    ///   - day: A day that exists in that month (29 February included)
    ///   - type: Which anniversaries (default: the editors' selection)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: The entries, newest year first as Wikipedia orders them; empty
    ///   when the edition has none of that kind
    /// - Throws: ``WikipediaError/invalidQuery(_:)`` for a date that does not exist
    static func onThisDay(
        month: Int,
        day: Int,
        type: WikipediaEventType = .selected,
        language: WikipediaLanguage = .english
    ) async throws(WikipediaError) -> [WikipediaHistoricalEvent] {
        try Validation.monthDay(month: month, day: day)
        do {
            let data = try await performRequest(url: WikipediaURLs.onThisDay(type: type, month: month, day: day, language: language))
            let response = try ResponseDecoding.decode([String: [WikipediaEventResponse]].self, from: data)
            return (response[type.rawValue] ?? []).map { WikipediaHistoricalEvent(response: $0, language: language) }
        } catch WikipediaError.networkError(let message) where message.hasPrefix("404") {
            return []   // an edition without this feed
        }
    }
}
