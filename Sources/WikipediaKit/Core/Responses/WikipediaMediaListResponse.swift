//
//  WikipediaMediaListResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The REST `page/media-list` body.
internal struct WikipediaMediaListResponse: Decodable {
    let items: [WikipediaMediaItemResponse]
}
