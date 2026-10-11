//
//  WikipediaDailyFeed.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Wikipedia's front page for a day: the featured article, the most-read
/// articles, the news, the picture of the day, "Did you know…" and a
/// selection of anniversaries. Sections a language edition does not carry are
/// empty.
public struct WikipediaDailyFeed: Sendable {

    /// The day this feed is for.
    public let date: Date

    /// Today's featured article, if the edition has one.
    public let featured: WikipediaArticle?

    /// The articles most read on the previous day, most read first.
    public let mostRead: [WikipediaTrendingArticle]

    /// The "In the news" stories.
    public let news: [WikipediaNewsStory]

    /// The picture of the day.
    public let picture: WikipediaPicture?

    /// "Did you know…" facts, as plain text.
    public let didYouKnow: [String]

    /// A selection of anniversaries of this date.
    public let onThisDay: [WikipediaHistoricalEvent]
}
