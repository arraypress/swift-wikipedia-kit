//
//  WikipediaMediaItem+Response.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

extension WikipediaMediaItem {

    /// A media item; its URL is the last — largest — rendition in `srcset`.
    init(response: WikipediaMediaItemResponse) {
        self.init(title: response.title, type: response.type,
                  url: response.srcset?.last.flatMap { WikipediaFormat.mediaURL($0.src) },
                  isLeadImage: response.leadImage ?? false,
                  caption: response.caption.map { WikipediaText.clean($0.text) })
    }
}
