//
//  WikipediaEdition.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One Wikipedia that exists, from Wikimedia's own list.
public struct WikipediaEdition: Sendable, Hashable, Identifiable {

    /// The edition, ready to pass to any call.
    public let language: WikipediaLanguage

    /// The language's name in that language, as Wikimedia gives it.
    public let name: String

    /// The language's name in English.
    public let englishName: String

    /// Whether the edition is closed: read-only, no longer written.
    public let isClosed: Bool

    /// The edition code.
    public var id: String { language.code }
}
