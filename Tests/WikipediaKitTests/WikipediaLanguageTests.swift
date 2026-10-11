//
//  WikipediaLanguageTests.swift
//  WikipediaKitTests
//
//  Created by David Sherlock on 2026.
//
//  Any edition, not only the 20 constants: code parsing offline, and the edges
//  that only the network can show — an edition that does not exist, the site
//  matrix — live.
//

import XCTest
@testable import WikipediaKit

final class WikipediaLanguageTests: XCTestCase {

    func testCodesBecomeEditions() {
        XCTAssertEqual(WikipediaLanguage(code: "cy")?.code, "cy")
        XCTAssertEqual(WikipediaLanguage(code: " EN ")?.code, "en", "case and spaces ignored")
        XCTAssertEqual(WikipediaLanguage(code: "simple")?.code, "simple")
        XCTAssertEqual(WikipediaLanguage(code: "be-tarask")?.code, "be-tarask")
        XCTAssertEqual(WikipediaLanguage(code: "zh-min-nan")?.code, "zh-min-nan")
    }

    func testTheSevenISOCodesThatAreNotTheirSubdomain() {
        let expected = ["gsw": "als", "lzh": "zh-classical", "nan": "zh-min-nan", "rup": "roa-rup",
                        "sgs": "bat-smg", "vro": "fiu-vro", "yue": "zh-yue"]
        for (iso, subdomain) in expected {
            XCTAssertEqual(WikipediaLanguage(code: iso)?.code, subdomain, iso)
        }
    }

    func testTextThatCannotBeACode() {
        for junk in ["", "x", "english", "123", "en_GB", "toolongpart-x", "e n", "en.", "-en"] {
            XCTAssertNil(WikipediaLanguage(code: junk), junk)
        }
    }

    func testTheConstantsStillBehaveLikeTheEnumDid() {
        XCTAssertEqual(WikipediaLanguage.allCases.count, 20)
        XCTAssertEqual(WikipediaLanguage(rawValue: "de"), .german)
        let name: String
        switch WikipediaLanguage.german {
        case .english: name = "english"
        case .german: name = "german"
        default: name = "other"
        }
        XCTAssertEqual(name, "german")
    }

    func testNamesBeyondTheTwenty() {
        XCTAssertEqual(WikipediaLanguage(code: "cy")?.englishName, "Welsh")
        XCTAssertEqual(WikipediaLanguage(code: "cy")?.name, "Cymraeg")
        XCTAssertEqual(WikipediaLanguage(code: "yue")?.englishName, "Cantonese")
        XCTAssertEqual(WikipediaLanguage(code: "simple")?.name, "Simple English")
    }

    // MARK: - Live

    func testLiveAnEditionThatDoesNotExist() async throws {
        do {
            _ = try await WikipediaKit.search("x", language: WikipediaLanguage(code: "qq")!)
            XCTFail("qq.wikipedia.org should not resolve")
        } catch WikipediaError.invalidLanguage(let code) {
            XCTAssertEqual(code, "qq")
        }
    }

    func testLiveWelsh() async throws {
        let results = try await WikipediaKit.search("Caerdydd", language: WikipediaLanguage(code: "cy")!, limit: 2)
        XCTAssertEqual(results.first?.title, "Caerdydd")
    }

    func testLiveTheSiteMatrix() async throws {
        let editions = try await WikipediaKit.languages()
        XCTAssertGreaterThan(editions.count, 300)
        XCTAssertTrue(editions.contains { $0.language.code == "zh-yue" && $0.englishName == "Cantonese" })
        XCTAssertTrue(editions.contains { $0.isClosed })
        XCTAssertTrue(WikipediaLanguage.allCases.allSatisfy { constant in editions.contains { $0.language == constant } })
    }
}
