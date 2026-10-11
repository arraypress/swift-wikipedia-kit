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
        // The readable title: in the daily feed `title` is the page key
        // ("List_of_equations" — 109 of a day's 120 feed articles).
        let title = summary.titles?.normalized ?? summary.title.replacingOccurrences(of: "_", with: " ")
        self.init(
            title: title,
            extract: summary.extract ?? "",
            description: summary.description,
            thumbnail: summary.thumbnail.flatMap { thumbnail in
                URL(string: thumbnail.source).map { WikipediaImage(source: $0, width: thumbnail.width, height: thumbnail.height) }
            },
            url: summary.content_urls?.desktop.page
                ?? WikipediaURLs.article(title: title, languageCode: language.code)
                ?? URL(string: "https://\(language.code).wikipedia.org")!,
            pageId: summary.pageid,
            language: language,
            lastModified: summary.timestamp
        )
    }
}
