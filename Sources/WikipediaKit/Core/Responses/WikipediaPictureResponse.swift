//
//  WikipediaPictureResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The feed's picture of the day.
internal struct WikipediaPictureResponse: Decodable {
    let title: String
    let thumbnail: WikipediaThumbnailResponse?
    let image: WikipediaThumbnailResponse
    let file_page: String?
    let artist: WikipediaTextResponse?
    let credit: WikipediaTextResponse?
    let license: WikipediaLicenseResponse?
    let description: WikipediaTextResponse?
}
