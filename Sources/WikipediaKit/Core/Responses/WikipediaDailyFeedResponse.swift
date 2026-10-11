//
//  WikipediaDailyFeedResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The whole `feed/featured/{date}` body. Every section is optional: a
/// language edition carries only some of them, and an old date may lack most.
internal struct WikipediaDailyFeedResponse: Decodable {
    let tfa: WikipediaSummaryResponse?
    let mostread: WikipediaMostReadResponse?
    let news: [WikipediaNewsResponse]?
    let image: WikipediaPictureResponse?
    let dyk: [WikipediaTextResponse]?
    let onthisday: [WikipediaEventResponse]?
}
