//
//  WikipediaDailyFeed+Response.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  The feed's response mapped onto the public models — every section tolerated missing.
//

import Foundation

extension WikipediaDailyFeed {

    /// A feed from the `feed/featured` body.
    init(response: WikipediaDailyFeedResponse, date: Date, language: WikipediaLanguage) {
        self.init(
            date: date,
            featured: response.tfa.map { WikipediaArticle(summary: $0, language: language) },
            mostRead: (response.mostread?.articles ?? [])
                .map { WikipediaTrendingArticle(article: WikipediaArticle(summary: $0.summary, language: language), views: $0.views, rank: $0.rank) }
                .sorted { $0.rank < $1.rank },
            news: (response.news ?? []).map {
                WikipediaNewsStory(text: WikipediaText.clean($0.story), articles: $0.links.map { WikipediaArticle(summary: $0, language: language) })
            },
            picture: response.image.flatMap(WikipediaPicture.init(response:)),
            didYouKnow: (response.dyk ?? []).map { WikipediaText.clean($0.text) },
            onThisDay: (response.onthisday ?? []).map { WikipediaHistoricalEvent(response: $0, language: language) }
        )
    }
}
