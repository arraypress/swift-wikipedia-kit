//
//  WikipediaMediaItemResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One media item of a page.
internal struct WikipediaMediaItemResponse: Decodable {
    let title: String
    let type: String
    let leadImage: Bool?
    let caption: WikipediaTextResponse?
    let srcset: [WikipediaSourceResponse]?
}
