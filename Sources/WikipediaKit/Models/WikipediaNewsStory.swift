//
//  WikipediaNewsStory.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One "In the news" story.
public struct WikipediaNewsStory: Sendable {

    /// The story as plain text.
    public let text: String

    /// The articles the story links to.
    public let articles: [WikipediaArticle]
}
