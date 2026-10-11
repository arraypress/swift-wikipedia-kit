//
//  WikipediaPicture.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The picture of the day, with what is needed to credit it.
public struct WikipediaPicture: Sendable {

    /// The file's title, e.g. `File:Cantona.jpg`.
    public let title: String

    /// What it shows, as plain text.
    public let description: String?

    /// The full-size image.
    public let image: WikipediaImage

    /// A smaller rendition, when given.
    public let thumbnail: WikipediaImage?

    /// Who made it, as plain text.
    public let artist: String?

    /// The credit line, as plain text.
    public let credit: String?

    /// The licence's name, e.g. `CC BY-SA 4.0`.
    public let license: String?

    /// The licence's text.
    public let licenseURL: URL?

    /// The file's page on Wikimedia Commons.
    public let filePage: URL?
}
