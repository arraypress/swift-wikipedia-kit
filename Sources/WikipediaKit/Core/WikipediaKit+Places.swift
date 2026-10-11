//
//  WikipediaKit+Places.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Articles about places: what is near a point, and where an article is.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension WikipediaKit {

    /// Articles about places near a point, nearest first.
    ///
    /// ```swift
    /// let around = try await WikipediaKit.nearby(latitude: 51.5074, longitude: -0.1278, radius: 1_000)
    /// ```
    ///
    /// - Parameters:
    ///   - latitude: -90 to 90
    ///   - longitude: -180 to 180
    ///   - radius: Metres, 10–10,000 (the API's own limits; default 1,000)
    ///   - limit: At most this many, 1–500 (default 10)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: The articles, nearest first; empty where there are none (the open sea)
    /// - Throws: ``WikipediaError/invalidQuery(_:)`` for coordinates or a radius out of range
    static func nearby(
        latitude: Double,
        longitude: Double,
        radius: Int = 1_000,
        limit: Int = 10,
        language: WikipediaLanguage = .english
    ) async throws(WikipediaError) -> [WikipediaNearbyArticle] {
        try Validation.coordinates(latitude: latitude, longitude: longitude)
        try Validation.radius(radius)
        let url = WikipediaURLs.nearby(latitude: latitude, longitude: longitude, radius: radius,
                                       limit: max(1, min(500, limit)), language: language)
        let response = try ResponseDecoding.decode(WikipediaGeoSearchResponse.self, from: try await performRequest(url: url))
        return response.query.geosearch
            .map { WikipediaNearbyArticle(title: $0.title, pageId: $0.pageid,
                                          coordinates: WikipediaCoordinates(latitude: $0.lat, longitude: $0.lon), distance: $0.dist) }
            .sorted { $0.distance < $1.distance }
    }

    /// Where an article's subject is.
    ///
    /// - Returns: Its primary coordinates; `nil` for an article without a
    ///   location (most people and ideas) or one that does not exist
    /// - Throws: ``WikipediaError`` on a bad title or a failed request
    static func coordinates(
        of title: String,
        language: WikipediaLanguage = .english
    ) async throws(WikipediaError) -> WikipediaCoordinates? {
        try Validation.articleTitle(title)
        guard let pages = try queryPages(try await performRequest(url: WikipediaURLs.coordinates(title: title, language: language))) else { return nil }
        for (key, value) in pages where key != "-1" {
            guard let page = value as? [String: Any], let first = (page["coordinates"] as? [[String: Any]])?.first,
                  let lat = first["lat"] as? Double, let lon = first["lon"] as? Double else { continue }
            return WikipediaCoordinates(latitude: lat, longitude: lon)
        }
        return nil
    }
}
