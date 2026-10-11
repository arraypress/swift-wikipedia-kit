//
//  WikipediaPageViewsItem.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One day of views; `timestamp` is `yyyyMMddHH` in UTC.
internal struct WikipediaPageViewsItem: Decodable {
    let timestamp: String
    let views: Int
}
