//
//  WikipediaSearchResult+Reading.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension WikipediaSearchResult {

    /// Minutes to read the full article, at 200 words a minute; at least one.
    var estimatedReadingTime: Int { Reading.minutes(words: wordCount) }

    /// Whether this result is a strong match (a relevance of 1.5 or more).
    var isHighlyRelevant: Bool { relevanceScore >= 1.5 }
}
