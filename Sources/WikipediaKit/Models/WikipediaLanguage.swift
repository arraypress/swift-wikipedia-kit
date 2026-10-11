//
//  WikipediaLanguage.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Any of Wikipedia's language editions — not only the 20 with a name built in.
//

import Foundation

/// A Wikipedia language edition: the 20 most-used as constants (`.german`), and any
/// other by its code (`WikipediaLanguage(code: "cy")` for Welsh).
///
/// A struct rather than an enum since 2.0, so that all 364 editions are reachable;
/// `.english`, `rawValue`, `allCases` and `case .german:` patterns all still work.
/// ``WikipediaKit/languages()`` lists every edition Wikipedia runs.
public struct WikipediaLanguage: RawRepresentable, Hashable, Sendable, CaseIterable {

    /// The edition's subdomain — `en`, `zh-yue`, `simple` — which is what every
    /// URL is built from.
    public let rawValue: String

    /// English.
    public static let english = WikipediaLanguage(edition: "en")

    /// Spanish.
    public static let spanish = WikipediaLanguage(edition: "es")

    /// French.
    public static let french = WikipediaLanguage(edition: "fr")

    /// German.
    public static let german = WikipediaLanguage(edition: "de")

    /// Italian.
    public static let italian = WikipediaLanguage(edition: "it")

    /// Portuguese.
    public static let portuguese = WikipediaLanguage(edition: "pt")

    /// Russian.
    public static let russian = WikipediaLanguage(edition: "ru")

    /// Japanese.
    public static let japanese = WikipediaLanguage(edition: "ja")

    /// Chinese.
    public static let chinese = WikipediaLanguage(edition: "zh")

    /// Arabic.
    public static let arabic = WikipediaLanguage(edition: "ar")

    /// Hindi.
    public static let hindi = WikipediaLanguage(edition: "hi")

    /// Korean.
    public static let korean = WikipediaLanguage(edition: "ko")

    /// Dutch.
    public static let dutch = WikipediaLanguage(edition: "nl")

    /// Polish.
    public static let polish = WikipediaLanguage(edition: "pl")

    /// Swedish.
    public static let swedish = WikipediaLanguage(edition: "sv")

    /// Norwegian.
    public static let norwegian = WikipediaLanguage(edition: "no")

    /// Danish.
    public static let danish = WikipediaLanguage(edition: "da")

    /// Finnish.
    public static let finnish = WikipediaLanguage(edition: "fi")

    /// Turkish.
    public static let turkish = WikipediaLanguage(edition: "tr")

    /// Czech.
    public static let czech = WikipediaLanguage(edition: "cs")

    /// The 20 editions with names built in. Every other edition is reachable
    /// through ``init(code:)``.
    public static let allCases: [WikipediaLanguage] = [.english, .spanish, .french, .german, .italian, .portuguese, .russian, .japanese, .chinese, .arabic, .hindi, .korean, .dutch, .polish, .swedish, .norwegian, .danish, .finnish, .turkish, .czech]

    /// An edition by its code: the subdomain (`en`, `zh-yue`, `simple`) or the
    /// ISO language code where the two differ (`yue` → `zh-yue`). Case and
    /// surrounding spaces are ignored.
    ///
    /// - Returns: `nil` when the text cannot be an edition code. Whether the
    ///   edition exists is only known once a request is made — an unknown one
    ///   throws ``WikipediaError/invalidLanguage(_:)`` — or from
    ///   ``WikipediaKit/languages()``.
    public init?(code: String) {
        guard let edition = LanguageCodes.edition(for: code) else { return nil }
        self.rawValue = edition
    }

    /// The same as ``init(code:)``.
    public init?(rawValue: String) {
        self.init(code: rawValue)
    }

    /// A known-good edition code.
    init(edition: String) {
        self.rawValue = edition
    }

    /// The edition's code — its subdomain.
    public var code: String { rawValue }

    /// The language's name in that language — "Deutsch", "Cymraeg".
    public var name: String { LanguageCodes.nativeName(rawValue) }

    /// The language's name in English — "German", "Welsh".
    public var englishName: String { LanguageCodes.englishName(rawValue) }
}
