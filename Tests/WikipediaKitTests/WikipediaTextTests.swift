//
//  WikipediaTextTests.swift
//  WikipediaKitTests
//
//  Created by David Sherlock on 2026.
//
//  The pure text helpers, offline — each test pins a bug found against the live
//  API in October 2026.
//

import XCTest
@testable import WikipediaKit

final class WikipediaTextTests: XCTestCase {

    func testSnippetsLoseTagsAndEntities() {
        let raw = #"&quot;To be, or not to be&quot; is a <span class="searchmatch">monologue</span> &amp; more &#039;x&#039; &#x27;y&#x27;"#
        XCTAssertEqual(WikipediaText.clean(raw), #""To be, or not to be" is a monologue & more 'x' 'y'"#)
    }

    func testAnUnknownEntityAndABareAmpersandSurvive() {
        XCTAssertEqual(WikipediaText.decodeEntities("AT&T &bogus; &"), "AT&T &bogus; &")
    }

    func testRelevanceIgnoresPunctuationAndHTML() {
        // "Observer (quantum physics)" scored 0.0 for "quantum physics": the
        // brackets stopped both words matching a whitespace split.
        XCTAssertEqual(WikipediaText.relevance(query: "quantum physics", title: "Observer (quantum physics)", snippet: ""), 2.0)
        // A word found only inside the snippet's match markup counts.
        XCTAssertEqual(WikipediaText.relevance(query: "quantum physics", title: "Quantum mechanics",
                                               snippet: #"<span class="searchmatch">physics</span> of the very small"#), 1.5)
        XCTAssertEqual(WikipediaText.relevance(query: "   ", title: "Anything", snippet: ""), 0)
    }

    func testTheFeaturedDateIsGregorianWhateverTheCalendar() throws {
        // 2026-10-11 is 2569 in the Buddhist calendar; the feed 404'd on that.
        var buddhist = Calendar(identifier: .buddhist)
        buddhist.timeZone = .current
        let date = try XCTUnwrap(buddhist.date(from: DateComponents(year: 2569, month: 10, day: 11, hour: 12)))
        XCTAssertEqual(WikipediaText.featuredPath(for: date), "2026/10/11")
        XCTAssertTrue(WikipediaURLs.featured(date: date, language: .english).absoluteString.hasSuffix("/feed/featured/2026/10/11"))
    }

    func testABadShapeIsAParseErrorNotADecodingError() {
        XCTAssertThrowsError(try ResponseDecoding.decode(WikipediaFeaturedResponse.self, from: Data("{}".utf8))) { error in
            guard case WikipediaError.parseError = error else { return XCTFail("got \(error)") }
        }
    }

    func testTheUserAgentCarriesAContact() {
        XCTAssertTrue(WikipediaKit.userAgent.contains("https://github.com/arraypress/swift-wikipedia-kit"))
    }

    func testArticleLinksUseUnderscores() {
        XCTAssertEqual(WikipediaURLs.article(title: "Alan Turing", languageCode: "en")?.absoluteString, "https://en.wikipedia.org/wiki/Alan_Turing")
    }

    func testReadingFigures() {
        XCTAssertEqual(Reading.minutes(words: 0), 1)
        XCTAssertEqual(Reading.minutes(words: 1_000), 5)
        XCTAssertEqual(Reading.lengthCategory(words: 49), .stub)
        XCTAssertEqual(Reading.lengthCategory(words: 1_000), .veryLong)
        XCTAssertEqual(Reading.wordCount("one  two\nthree"), 3)
    }

    func testImageShape() {
        XCTAssertEqual(ImageShape.aspectRatio(width: 200, height: 0), 1.0)
        XCTAssertTrue(ImageShape.isSquare(width: 105, height: 100))
        XCTAssertFalse(ImageShape.isSquare(width: 120, height: 100))
    }
}
