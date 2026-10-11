//
//  WikipediaEndpointTests.swift
//  WikipediaKitTests
//
//  Created by David Sherlock on 2026.
//
//  The 1.2 endpoints. Offline: every input rule, conversion and URL, and the
//  daily feed decoded from a hand-made body with sections missing and page-key
//  titles. Live: one call each, skipped when Wikimedia refuses (403/429).
//

import XCTest
@testable import WikipediaKit

final class WikipediaEndpointTests: XCTestCase {

    // MARK: - Validation

    func testDatesThatExistPassAndOthersDoNot() throws {
        XCTAssertNoThrow(try Validation.monthDay(month: 2, day: 29))
        XCTAssertNoThrow(try Validation.monthDay(month: 12, day: 31))
        for (month, day) in [(2, 30), (4, 31), (13, 1), (0, 1), (1, 0), (1, 32)] {
            XCTAssertThrowsError(try Validation.monthDay(month: month, day: day), "\(month)/\(day)")
        }
    }

    func testCoordinatesAndRadius() {
        XCTAssertNoThrow(try Validation.coordinates(latitude: 90, longitude: -180))
        XCTAssertThrowsError(try Validation.coordinates(latitude: 90.0001, longitude: 0))
        XCTAssertThrowsError(try Validation.coordinates(latitude: 0, longitude: 180.5))
        XCTAssertThrowsError(try Validation.coordinates(latitude: .nan, longitude: 0))
        XCTAssertThrowsError(try Validation.coordinates(latitude: 0, longitude: .infinity))
        XCTAssertNoThrow(try Validation.radius(10))
        XCTAssertNoThrow(try Validation.radius(10_000))
        XCTAssertThrowsError(try Validation.radius(9))
        XCTAssertThrowsError(try Validation.radius(10_001))
    }

    func testARangeMustRunForwards() {
        let now = Date()
        XCTAssertNoThrow(try Validation.dateRange(from: now, to: now))
        XCTAssertThrowsError(try Validation.dateRange(from: now, to: now.addingTimeInterval(-1)))
    }

    // MARK: - Formats and URLs

    func testPageViewsTitlesEscapeTheSlash() {
        XCTAssertEqual(WikipediaFormat.pageViewsTitle("AC/DC"), "AC%2FDC")
        XCTAssertEqual(WikipediaFormat.pageViewsTitle("Ada Lovelace"), "Ada_Lovelace")
        XCTAssertEqual(WikipediaFormat.pageViewsTitle("100% Pure?"), "100%25_Pure%3F")
        XCTAssertEqual(WikipediaFormat.pageViewsTitle("東京"), "%E6%9D%B1%E4%BA%AC")
    }

    func testPageViewsDaysAreUTCAndGregorian() throws {
        let date = try XCTUnwrap(WikipediaFormat.utc.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 23)))
        XCTAssertEqual(WikipediaFormat.pageViewsDay(date), "20261001")
        XCTAssertEqual(WikipediaFormat.pageViewsDate("2026100100"), WikipediaFormat.utc.date(from: DateComponents(year: 2026, month: 10, day: 1)))
        XCTAssertNil(WikipediaFormat.pageViewsDate("2026"))
    }

    func testMediaURLsGainTheirScheme() {
        XCTAssertEqual(WikipediaFormat.mediaURL("//upload.wikimedia.org/a.jpg")?.absoluteString, "https://upload.wikimedia.org/a.jpg")
        XCTAssertEqual(WikipediaFormat.mediaURL("https://x.org/b.jpg")?.absoluteString, "https://x.org/b.jpg")
    }

    func testCategoryNamesLoseTheirTranslatedNamespace() {
        XCTAssertEqual(WikipediaFormat.categoryName("Category:1912 births"), "1912 births")
        XCTAssertEqual(WikipediaFormat.categoryName("Kategorie:Mathematiker (20. Jahrhundert)"), "Mathematiker (20. Jahrhundert)")
        XCTAssertEqual(WikipediaFormat.categoryName("Category:Films: 1990s"), "Films: 1990s")
        XCTAssertEqual(WikipediaFormat.categoryName("NoPrefix"), "NoPrefix")
    }

    func testURLs() {
        XCTAssertEqual(WikipediaURLs.onThisDay(type: .births, month: 2, day: 9, language: .german).absoluteString,
                       "https://de.wikipedia.org/api/rest_v1/feed/onthisday/births/02/09")
        XCTAssertEqual(WikipediaURLs.pageViews(title: "AC/DC", from: Date(timeIntervalSince1970: 0), to: Date(timeIntervalSince1970: 86_400),
                                               language: .english).absoluteString,
                       "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia/all-access/user/AC%2FDC/daily/19700101/19700102")
        let nearby = WikipediaURLs.nearby(latitude: 51.5, longitude: -0.12, radius: 500, limit: 5, language: .english).absoluteString
        XCTAssertTrue(nearby.contains("gscoord=51.5%7C-0.12") && nearby.contains("gsradius=500"), nearby)
        XCTAssertTrue(WikipediaURLs.categories(title: "X", cursor: "1|a", language: .english).absoluteString.contains("clcontinue=1%7Ca"))
    }

    // MARK: - The daily feed, decoded

    func testAFeedWithSectionsMissingAndPageKeyTitles() throws {
        let body = #"""
        {"tfa": {"title": "List_of_equations", "titles": {"normalized": "List of equations"}, "pageid": 1,
                 "extract": "An extract", "content_urls": {"desktop": {"page": "https://en.wikipedia.org/wiki/List_of_equations"}}},
         "mostread": {"articles": [
            {"title": "B_b", "pageid": 3, "views": 10, "rank": 2},
            {"title": "A_a", "titles": {"normalized": "A a"}, "pageid": 2, "views": 99, "rank": 1}]},
         "news": [{"story": "<b>Big</b> &amp; news", "links": [{"title": "Big_news", "pageid": 4}]}],
         "dyk": [{"html": "<b>x</b>", "text": "... that &quot;y&quot;?"}]}
        """#
        let feed = WikipediaDailyFeed(response: try ResponseDecoding.decode(WikipediaDailyFeedResponse.self, from: Data(body.utf8)),
                                      date: Date(), language: .english)
        XCTAssertEqual(feed.featured?.title, "List of equations")
        XCTAssertEqual(feed.mostRead.map(\.article.title), ["A a", "B b"], "sorted by rank; page keys made readable")
        XCTAssertEqual(feed.mostRead.first?.views, 99)
        XCTAssertEqual(feed.mostRead.last?.article.url.absoluteString, "https://en.wikipedia.org/wiki/B_b", "a missing URL is rebuilt")
        XCTAssertEqual(feed.mostRead.last?.article.extract, "", "a missing extract is empty, not a failure")
        XCTAssertEqual(feed.news.first?.text, "Big & news")
        XCTAssertEqual(feed.didYouKnow, [#"... that "y"?"#])
        XCTAssertNil(feed.picture)
        XCTAssertTrue(feed.onThisDay.isEmpty)
    }

    func testAnEmptyFeedBodyDecodes() throws {
        let feed = WikipediaDailyFeed(response: try ResponseDecoding.decode(WikipediaDailyFeedResponse.self, from: Data("{}".utf8)),
                                      date: Date(), language: .hindi)
        XCTAssertNil(feed.featured)
        XCTAssertTrue(feed.mostRead.isEmpty && feed.news.isEmpty && feed.didYouKnow.isEmpty)
    }

    // MARK: - Live

    private func live<T>(_ body: () async throws -> T) async throws -> T {
        do { return try await body() } catch WikipediaError.rateLimited {
            throw XCTSkip("rate limited")
        } catch WikipediaError.networkError(let message) where message.hasPrefix("403") {
            throw XCTSkip("Wikipedia access restricted (HTTP 403)")
        }
    }

    func testLiveDailyFeed() async throws {
        let feed = try await live { try await WikipediaKit.dailyFeed() }
        XCTAssertFalse(feed.mostRead.isEmpty)
        XCTAssertFalse(feed.mostRead.contains { $0.article.title.contains("_") }, "titles are readable")
        let old = try await live { try await WikipediaKit.dailyFeed(for: Date(timeIntervalSince1970: 1_300_000_000)) }   // 2011: no feed
        XCTAssertNil(old.featured)
    }

    func testLiveOnThisDay() async throws {
        let holidays = try await live { try await WikipediaKit.onThisDay(month: 2, day: 29, type: .holidays) }
        XCTAssertTrue(holidays.allSatisfy { $0.year == nil })
        let births = try await live { try await WikipediaKit.onThisDay(month: 10, day: 11, type: .births) }
        XCTAssertFalse(births.isEmpty)
    }

    func testLivePlaces() async throws {
        let around = try await live { try await WikipediaKit.nearby(latitude: 48.8584, longitude: 2.2945, radius: 500) }
        XCTAssertFalse(around.isEmpty)
        XCTAssertEqual(around.map(\.distance), around.map(\.distance).sorted())
        let sea = try await live { try await WikipediaKit.nearby(latitude: 0, longitude: -150, radius: 10_000) }
        XCTAssertTrue(sea.isEmpty)
        let tower = try await live { try await WikipediaKit.coordinates(of: "Eiffel Tower") }
        XCTAssertEqual(tower?.latitude ?? 0, 48.858, accuracy: 0.01)
        let person = try await live { try await WikipediaKit.coordinates(of: "Alan Turing") }
        XCTAssertNil(person)
    }

    func testLivePageDetails() async throws {
        let suggestions = try await live { try await WikipediaKit.suggestions("alan tur", limit: 3) }
        XCTAssertEqual(suggestions.first, "Alan Turing")
        let item = try await live { try await WikipediaKit.wikidataID(for: "Turing") }   // a redirect
        XCTAssertEqual(item, "Q7251")
        let views = try await live { try await WikipediaKit.pageViews("AC/DC", from: Date().addingTimeInterval(-8 * 86_400)) }
        XCTAssertFalse(views.isEmpty)
        let none = try await live { try await WikipediaKit.pageViews("Zzzqqq No Such Article 12345", from: Date().addingTimeInterval(-3 * 86_400)) }
        XCTAssertTrue(none.isEmpty)
        let media = try await live { try await WikipediaKit.media(of: "Alan Turing") }
        XCTAssertTrue(media.contains { $0.isLeadImage })
        XCTAssertTrue(media.allSatisfy { $0.url?.scheme == "https" })
        let categories = try await live { try await WikipediaKit.categories(of: "Alan Turing") }
        XCTAssertTrue(categories.contains("1912 births"))
        XCTAssertFalse(categories.contains { $0.hasPrefix("Category:") })
    }
}
