//
//  WikipediaHistoricalEvent+Response.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

extension WikipediaHistoricalEvent {

    /// An event from an on-this-day entry.
    init(response: WikipediaEventResponse, language: WikipediaLanguage) {
        self.init(text: WikipediaText.clean(response.text), year: response.year,
                  articles: (response.pages ?? []).map { WikipediaArticle(summary: $0, language: language) })
    }
}
