//
//  WikipediaMediaItem.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// An image, video or sound file used on an article.
public struct WikipediaMediaItem: Sendable {

    /// The file's title, e.g. `File:Alan_turing_header.jpg`.
    public let title: String

    /// `image`, `video` or `audio`.
    public let type: String

    /// The largest rendition the page uses.
    public let url: URL?

    /// Whether it is the article's lead image.
    public let isLeadImage: Bool

    /// Its caption, as plain text.
    public let caption: String?
}
