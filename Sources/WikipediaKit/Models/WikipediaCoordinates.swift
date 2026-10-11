//
//  WikipediaCoordinates.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A point on Earth, in decimal degrees.
public struct WikipediaCoordinates: Sendable, Hashable {

    /// Latitude, -90 to 90.
    public let latitude: Double

    /// Longitude, -180 to 180.
    public let longitude: Double

    /// A point.
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
