//
//  WikipediaGeoSearchItem.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One article near a point: its place and its distance in metres.
internal struct WikipediaGeoSearchItem: Decodable {
    let pageid: Int
    let title: String
    let lat: Double
    let lon: Double
    let dist: Double
}
