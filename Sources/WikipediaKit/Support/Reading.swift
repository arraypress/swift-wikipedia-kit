//
//  Reading.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Word counts and reading time, written once for every model that shows them.
//

import Foundation

/// Reading figures for article text.
enum Reading {

    /// Reading speed, in words a minute.
    static let wordsPerMinute = 200

    /// Words, split on whitespace.
    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    /// Minutes to read this many words; at least one.
    static func minutes(words: Int) -> Int {
        max(1, words / wordsPerMinute)
    }

    /// How long a text of this many words is.
    static func lengthCategory(words: Int) -> ArticleLengthCategory {
        switch words {
        case 0..<50: return .stub
        case 50..<200: return .short
        case 200..<500: return .medium
        case 500..<1000: return .long
        default: return .veryLong
        }
    }
}
