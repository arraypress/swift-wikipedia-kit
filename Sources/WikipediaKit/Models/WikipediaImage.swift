//
//  WikipediaImage.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// An image with its dimensions — an article's thumbnail.
///
/// Shape figures (``aspectRatio``, ``isLandscape``…) are in
/// `Extensions/WikipediaImage+Shape.swift`.
public struct WikipediaImage: Sendable {

    /// Direct URL to the image file.
    public let source: URL

    /// Image width in pixels.
    public let width: Int

    /// Image height in pixels.
    public let height: Int

    internal init(source: URL, width: Int, height: Int) {
        self.source = source
        self.width = width
        self.height = height
    }
}
