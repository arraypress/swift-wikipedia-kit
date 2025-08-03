//
//  WikipediaImage.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Represents a Wikipedia image with dimensions.
///
/// Used for article thumbnails and other images associated with Wikipedia content.
public struct WikipediaImage: Sendable {
    /// Direct URL to the image file
    public let source: URL
    
    /// Image width in pixels
    public let width: Int
    
    /// Image height in pixels
    public let height: Int
    
    /// Aspect ratio of the image (width/height)
    public var aspectRatio: Double {
        guard height > 0 else { return 1.0 }
        return Double(width) / Double(height)
    }
    
    /// Whether the image is in landscape orientation
    public var isLandscape: Bool {
        return width > height
    }
    
    /// Whether the image is in portrait orientation
    public var isPortrait: Bool {
        return height > width
    }
    
    /// Whether the image is square (or nearly square)
    public var isSquare: Bool {
        let ratio = aspectRatio
        return ratio >= 0.9 && ratio <= 1.1
    }
    
    internal init(source: URL, width: Int, height: Int) {
        self.source = source
        self.width = width
        self.height = height
    }
}
