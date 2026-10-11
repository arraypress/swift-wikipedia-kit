//
//  WikipediaTextResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A piece of text the feed gives as both `html` and plain `text`.
internal struct WikipediaTextResponse: Decodable {
    let text: String
}
