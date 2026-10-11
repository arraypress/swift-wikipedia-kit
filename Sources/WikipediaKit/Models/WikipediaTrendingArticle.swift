//
//  WikipediaTrendingArticle.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// An article with how many times it was read.
public struct WikipediaTrendingArticle: Sendable, Identifiable {

    /// The article.
    public let article: WikipediaArticle

    /// Views on the day the list covers.
    public let views: Int

    /// Its position in the list, 1 = most read.
    public let rank: Int

    /// The article's page ID.
    public var id: Int { article.id }
}
