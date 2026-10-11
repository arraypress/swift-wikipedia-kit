//
//  WikipediaPicture+Response.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

extension WikipediaPicture {

    /// The picture of the day, or nil when its image URL is unusable.
    init?(response: WikipediaPictureResponse) {
        guard let source = URL(string: response.image.source) else { return nil }
        self.init(
            title: response.title,
            description: response.description.map { WikipediaText.clean($0.text) },
            image: WikipediaImage(source: source, width: response.image.width, height: response.image.height),
            thumbnail: response.thumbnail.flatMap { thumb in
                URL(string: thumb.source).map { WikipediaImage(source: $0, width: thumb.width, height: thumb.height) }
            },
            artist: response.artist.map { WikipediaText.clean($0.text) },
            credit: response.credit.map { WikipediaText.clean($0.text) },
            license: response.license?.type,
            licenseURL: response.license?.url.flatMap(URL.init(string:)),
            filePage: response.file_page.flatMap(URL.init(string:))
        )
    }
}
