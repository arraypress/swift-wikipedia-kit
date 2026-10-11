//
//  WikipediaArticle+Reading.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension WikipediaArticle {

    /// Minutes to read the summary, at 200 words a minute; at least one.
    var estimatedReadingTime: Int { Reading.minutes(words: Reading.wordCount(extract)) }

    /// How long the summary is: stub (< 50 words) to very long (1,000+).
    var lengthCategory: ArticleLengthCategory { Reading.lengthCategory(words: Reading.wordCount(extract)) }

    /// Whether this article has a thumbnail image.
    var hasThumbnail: Bool { thumbnail != nil }
}
