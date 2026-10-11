//
//  WikipediaText.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  The pure text work behind the API calls: cleaning search snippets, scoring
//  relevance, and spelling the featured-feed date. Kept apart so each can be
//  tested without the network.
//

import Foundation

/// Text helpers for Wikipedia's responses.
enum WikipediaText {

    /// A search snippet as plain text: tags removed and HTML entities decoded.
    ///
    /// The search API wraps matches in `<span class="searchmatch">` and escapes
    /// quotes, so a raw snippet reads `&quot;To be, or not to be&quot;`.
    static func clean(_ html: String) -> String {
        let text = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return decodeEntities(text)
    }

    /// The named entities the API uses, and any numeric one (`&#39;`, `&#x27;`).
    static func decodeEntities(_ text: String) -> String {
        guard text.contains("&") else { return text }
        let named = ["&quot;": "\"", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&apos;": "'", "&nbsp;": "\u{00A0}"]
        var result = ""
        var rest = Substring(text)
        while let amp = rest.firstIndex(of: "&") {
            result += rest[..<amp]
            let tail = rest[amp...]
            if let semicolon = tail.prefix(10).firstIndex(of: ";") {
                let entity = String(tail[...semicolon])
                if let plain = named[entity] {
                    result += plain
                    rest = tail[tail.index(after: semicolon)...]
                    continue
                }
                if entity.hasPrefix("&#") {
                    let body = entity.dropFirst(2).dropLast()
                    let value = body.first == "x" || body.first == "X"
                        ? UInt32(body.dropFirst(), radix: 16) : UInt32(body, radix: 10)
                    if let value, let scalar = Unicode.Scalar(value) {
                        result.unicodeScalars.append(scalar)
                        rest = tail[tail.index(after: semicolon)...]
                        continue
                    }
                }
            }
            result += "&"
            rest = tail.dropFirst()
        }
        return result + rest
    }

    /// Lower-cased words, punctuation dropped — so "(quantum physics)" yields
    /// "quantum" and "physics", which a whitespace split did not.
    static func words(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }

    /// How well a result matches a query: 2 for each query word in the title,
    /// 1 for each found only in the snippet, averaged over the query's words.
    static func relevance(query: String, title: String, snippet: String) -> Double {
        let queryWords = words(query)
        guard !queryWords.isEmpty else { return 0 }
        let titleWords = Set(words(title)), snippetWords = Set(words(clean(snippet)))
        let score = queryWords.reduce(0.0) { total, word in
            total + (titleWords.contains(word) ? 2 : snippetWords.contains(word) ? 1 : 0)
        }
        return score / Double(queryWords.count)
    }

    /// `yyyy/MM/dd` in the Gregorian calendar, whatever the device uses.
    ///
    /// A `DateFormatter` follows the user's calendar: on a Mac set to the
    /// Buddhist calendar, today is year 2569, and the featured feed answered
    /// that date with 404.
    static func featuredPath(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d/%02d/%02d", parts.year ?? 1970, parts.month ?? 1, parts.day ?? 1)
    }
}
