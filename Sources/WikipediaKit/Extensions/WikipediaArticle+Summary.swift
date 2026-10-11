//
//  WikipediaArticle+Summary.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

extension WikipediaArticle {

    /// An article from the REST summary — the shape the summary, random and
    /// featured endpoints all return.
    init(summary: WikipediaSummaryResponse, language: WikipediaLanguage) {
        self.init(
            title: summary.title,
            extract: summary.extract,
            description: summary.description,
            thumbnail: summary.thumbnail.flatMap { thumbnail in
                URL(string: thumbnail.source).map { WikipediaImage(source: $0, width: thumbnail.width, height: thumbnail.height) }
            },
            url: summary.content_urls.desktop.page,
            pageId: summary.pageid,
            language: language,
            lastModified: summary.timestamp
        )
    }
}
