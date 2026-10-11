//
//  WikipediaLicenseResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A picture's licence.
internal struct WikipediaLicenseResponse: Decodable {
    let type: String?
    let url: String?
}
