//
//  LanguageCodes.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Edition codes and the names shown for them.
//

import Foundation

/// Rules for Wikipedia edition codes.
enum LanguageCodes {

    /// Languages whose Wikipedia subdomain is not their ISO code (measured from
    /// the sitematrix, October 2026): these seven, and no others.
    static let subdomainForCode: [String: String] = [
        "gsw": "als", "lzh": "zh-classical", "nan": "zh-min-nan", "rup": "roa-rup",
        "sgs": "bat-smg", "vro": "fiu-vro", "yue": "zh-yue",
    ]

    /// Built-in names for the 20 constants and Simple English: (native, English).
    static let names: [String: (native: String, english: String)] = [
        "en": ("English", "English"),
        "es": ("Español", "Spanish"),
        "fr": ("Français", "French"),
        "de": ("Deutsch", "German"),
        "it": ("Italiano", "Italian"),
        "pt": ("Português", "Portuguese"),
        "ru": ("Русский", "Russian"),
        "ja": ("日本語", "Japanese"),
        "zh": ("中文", "Chinese"),
        "ar": ("العربية", "Arabic"),
        "hi": ("हिन्दी", "Hindi"),
        "ko": ("한국어", "Korean"),
        "nl": ("Nederlands", "Dutch"),
        "pl": ("Polski", "Polish"),
        "sv": ("Svenska", "Swedish"),
        "no": ("Norsk", "Norwegian"),
        "da": ("Dansk", "Danish"),
        "fi": ("Suomi", "Finnish"),
        "tr": ("Türkçe", "Turkish"),
        "cs": ("Čeština", "Czech"),
        "simple": ("Simple English", "Simple English"),
    ]

    /// The subdomain for a code, or nil when the text cannot be one. Every
    /// subdomain is two or three letters with optional hyphenated parts
    /// (`be-tarask`, `zh-min-nan`), except `simple`.
    static func edition(for code: String) -> String? {
        let lowered = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let edition = subdomainForCode[lowered] ?? lowered
        guard edition == "simple" || edition.range(of: "^[a-z]{2,3}(-[a-z]{2,12})*$", options: .regularExpression) != nil else {
            return nil
        }
        return edition
    }

    /// The ISO code behind a subdomain, for the system's language names.
    static func isoCode(_ edition: String) -> String {
        subdomainForCode.first { $0.value == edition }?.key ?? edition
    }

    /// The language's own name: built in, else the system's, else the code.
    static func nativeName(_ edition: String) -> String {
        if let known = names[edition] { return known.native }
        let iso = isoCode(edition)
        guard let name = Locale(identifier: iso).localizedString(forLanguageCode: iso) else { return edition }
        return name.prefix(1).uppercased() + name.dropFirst()
    }

    /// The language's English name: built in, else the system's, else the code.
    static func englishName(_ edition: String) -> String {
        if let known = names[edition] { return known.english }
        return Locale(identifier: "en").localizedString(forLanguageCode: isoCode(edition)) ?? edition
    }
}
