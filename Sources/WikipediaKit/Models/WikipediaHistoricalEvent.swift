//
//  WikipediaHistoricalEvent.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Something that happened on a date: an event, a birth, a death or a holiday.
public struct WikipediaHistoricalEvent: Sendable {

    /// What happened, as plain text.
    public let text: String

    /// The year; `nil` for holidays and observances.
    public let year: Int?

    /// The articles it mentions.
    public let articles: [WikipediaArticle]
}
