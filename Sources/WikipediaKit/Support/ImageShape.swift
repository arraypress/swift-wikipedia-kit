//
//  ImageShape.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The shape of an image from its pixel size.
enum ImageShape {

    /// Width over height; 1 for a zero height.
    static func aspectRatio(width: Int, height: Int) -> Double {
        height > 0 ? Double(width) / Double(height) : 1.0
    }

    /// Within 10% of square.
    static func isSquare(width: Int, height: Int) -> Bool {
        (0.9...1.1).contains(aspectRatio(width: width, height: height))
    }
}
