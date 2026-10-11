//
//  WikipediaImage+Shape.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension WikipediaImage {

    /// Width over height (1 for a zero height).
    var aspectRatio: Double { ImageShape.aspectRatio(width: width, height: height) }

    /// Whether the image is wider than tall.
    var isLandscape: Bool { width > height }

    /// Whether the image is taller than wide.
    var isPortrait: Bool { height > width }

    /// Whether the image is square, within 10%.
    var isSquare: Bool { ImageShape.isSquare(width: width, height: height) }
}
