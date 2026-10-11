//
//  WikipediaContent+Counts.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension WikipediaContent {

    /// Characters in the text.
    var characterCount: Int { text.count }

    /// Words, by whitespace — the figure a reading-time estimate needs.
    var wordCount: Int { Reading.wordCount(text) }
}
