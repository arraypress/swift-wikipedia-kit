//
//  WikipediaNearbyArticle.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// An article about a place near a point.
public struct WikipediaNearbyArticle: Sendable, Identifiable {

    /// Article title.
    public let title: String

    /// Wikipedia page ID.
    public let pageId: Int

    /// The place's coordinates.
    public let coordinates: WikipediaCoordinates

    /// Distance from the point searched, in metres.
    public let distance: Double

    /// The page ID.
    public var id: Int { pageId }
}
