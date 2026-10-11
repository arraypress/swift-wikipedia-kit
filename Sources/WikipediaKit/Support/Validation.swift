//
//  Validation.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Every input rule, checked before a request is made, as pure functions.
//

import Foundation

/// Input checks. Each throws ``WikipediaError/invalidQuery(_:)`` naming the problem.
enum Validation {

    /// A non-empty query of at most 300 characters.
    static func searchQuery(_ query: String) throws(WikipediaError) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WikipediaError.invalidQuery("Search query cannot be empty") }
        guard trimmed.count <= 300 else { throw WikipediaError.invalidQuery("Search query too long (max 300 characters)") }
    }

    /// A non-empty title of at most 255 characters.
    static func articleTitle(_ title: String) throws(WikipediaError) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WikipediaError.invalidQuery("Article title cannot be empty") }
        guard trimmed.count <= 255 else { throw WikipediaError.invalidQuery("Article title too long (max 255 characters)") }
    }

    /// A real calendar day — 29 February included, 30 February and month 13 not.
    static func monthDay(month: Int, day: Int) throws(WikipediaError) {
        // 2000 is a leap year, so 29 February passes; the year is not sent.
        guard (1...12).contains(month), let days = Calendar(identifier: .gregorian)
            .range(of: .day, in: .month, for: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2000, month: month).date!),
              days.contains(day) else {
            throw WikipediaError.invalidQuery("No such date: month \(month), day \(day)")
        }
    }

    /// A point on Earth.
    static func coordinates(latitude: Double, longitude: Double) throws(WikipediaError) {
        guard latitude.isFinite, longitude.isFinite, (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            throw WikipediaError.invalidQuery("Coordinates out of range: \(latitude), \(longitude)")
        }
    }

    /// The geosearch radius, which the API accepts from 10 to 10,000 metres.
    static func radius(_ metres: Int) throws(WikipediaError) {
        guard (10...10_000).contains(metres) else {
            throw WikipediaError.invalidQuery("Radius must be 10–10,000 metres, not \(metres)")
        }
    }

    /// A date range that runs forwards.
    static func dateRange(from start: Date, to end: Date) throws(WikipediaError) {
        guard start <= end else { throw WikipediaError.invalidQuery("The range ends before it starts") }
    }
}
