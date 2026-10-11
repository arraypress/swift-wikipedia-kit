//
//  WikipediaFormat.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Small conversions the newer endpoints need, written once and testable offline.
//

import Foundation

/// Conversions between Wikipedia's wire formats and Swift values.
enum WikipediaFormat {

    /// The Gregorian calendar in UTC — the pageviews API counts days in UTC.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// `yyyyMMdd` in UTC, whatever the device's calendar.
    static func pageViewsDay(_ date: Date) -> String {
        let parts = utc.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", parts.year ?? 1970, parts.month ?? 1, parts.day ?? 1)
    }

    /// The day of a pageviews `timestamp` (`yyyyMMddHH`, UTC) at midnight UTC.
    static func pageViewsDate(_ timestamp: String) -> Date? {
        let digits = Array(timestamp)
        guard digits.count >= 8, let year = Int(String(digits[0..<4])), let month = Int(String(digits[4..<6])),
              let day = Int(String(digits[6..<8])) else { return nil }
        return utc.date(from: DateComponents(year: year, month: month, day: day))
    }

    /// A title as one path segment of the pageviews API: spaces become
    /// underscores and `/` is escaped — "AC/DC" must be `AC%2FDC`, or the
    /// slash is read as a path separator.
    static func pageViewsTitle(_ title: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#%")
        return title.replacingOccurrences(of: " ", with: "_").addingPercentEncoding(withAllowedCharacters: allowed) ?? title
    }

    /// A media URL: `src` arrives protocol-relative (`//upload.wikimedia.org/…`).
    static func mediaURL(_ src: String) -> URL? {
        URL(string: src.hasPrefix("//") ? "https:" + src : src)
    }

    /// A category's name without its namespace, which is translated — `Category:`
    /// in English, `Kategorie:` in German — so everything up to the first colon goes.
    static func categoryName(_ title: String) -> String {
        guard let colon = title.firstIndex(of: ":") else { return title }
        return String(title[title.index(after: colon)...])
    }
}
