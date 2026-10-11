//
//  WikipediaTranslation.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One language an article also exists in.
public struct WikipediaTranslation: Sendable, Identifiable, Hashable {

    /// The language code, e.g. `de`.
    public let code: String

    /// The language's name in its own language, e.g. `Deutsch`.
    public let name: String

    /// The article's title in that language, which is often not a
    /// translation of the English one — `Alan Turing` is `ألان تورنج` in
    /// Arabic, and guessing the title from the code does not work.
    public let title: String

    /// The language code.
    public var id: String { code }
}
