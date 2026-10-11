//
//  WikipediaTranslation+URL.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension WikipediaTranslation {

    /// Where to read it.
    var url: URL? { WikipediaURLs.article(title: title, languageCode: code) }
}
