//
//  ArticleLengthCategory.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Categories for article length based on word count.
///
/// Helps users understand the scope and depth of an article
/// before deciding whether to read it.
public enum ArticleLengthCategory: String, CaseIterable, Sendable {
    case stub = "stub"
    case short = "short"
    case medium = "medium"
    case long = "long"
    case veryLong = "very_long"
    
    /// Human-readable description of the article length
    public var description: String {
        switch self {
        case .stub: return "Stub Article"
        case .short: return "Short Article"
        case .medium: return "Medium Article"
        case .long: return "Long Article"
        case .veryLong: return "Very Long Article"
        }
    }
    
    /// Detailed description with word count range
    public var detailedDescription: String {
        switch self {
        case .stub: return "Stub Article (< 50 words)"
        case .short: return "Short Article (50-200 words)"
        case .medium: return "Medium Article (200-500 words)"
        case .long: return "Long Article (500-1,000 words)"
        case .veryLong: return "Very Long Article (1,000+ words)"
        }
    }
    
    /// Estimated reading time range for this category
    public var readingTimeRange: ClosedRange<Int> {
        switch self {
        case .stub: return 1...1
        case .short: return 1...1
        case .medium: return 1...3
        case .long: return 3...5
        case .veryLong: return 5...10
        }
    }
}
