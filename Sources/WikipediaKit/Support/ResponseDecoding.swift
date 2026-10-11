//
//  ResponseDecoding.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// JSON decoding for the API's responses.
enum ResponseDecoding {

    /// Decodes a response, reporting a shape the API did not promise as
    /// ``WikipediaError/parseError(_:)`` — the documented error type — rather
    /// than a raw `DecodingError`.
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws(WikipediaError) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw WikipediaError.parseError(String(describing: error))
        }
    }
}
