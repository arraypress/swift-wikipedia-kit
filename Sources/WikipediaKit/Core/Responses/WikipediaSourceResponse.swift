//
//  WikipediaSourceResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One rendition of a media item; `src` is protocol-relative (`//…`).
internal struct WikipediaSourceResponse: Decodable {
    let src: String
    let scale: String?
}
