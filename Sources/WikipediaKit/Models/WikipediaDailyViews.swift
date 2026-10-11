//
//  WikipediaDailyViews.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// How many times an article was read on one day.
public struct WikipediaDailyViews: Sendable, Hashable {

    /// The day, at midnight UTC.
    public let date: Date

    /// Views by people (crawlers excluded) on all platforms.
    public let views: Int
}
