//
//  WikipediaURLs.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//
//  Every URL the library calls or hands back, built in one place and testable offline.
//

import Foundation

/// The URLs of Wikipedia's search, REST and article pages.
enum WikipediaURLs {

    /// `action=query&list=search`.
    static func search(query: String, language: WikipediaLanguage, limit: Int) -> URL {
        api(language, [("list", "search"), ("srsearch", query), ("srlimit", String(limit)), ("srprop", "snippet|wordcount")])
    }

    /// An article's full plain text (`prop=extracts&explaintext`).
    static func extract(title: String, language: WikipediaLanguage) -> URL {
        api(language, [("prop", "extracts"), ("explaintext", "1"), ("redirects", "1"), ("titles", title)])
    }

    /// An article's other-language versions. 500 is the API's own ceiling for an
    /// anonymous caller, and a well-linked article passes 200 — the default of
    /// 10 would silently return a tenth of the answer.
    static func langLinks(title: String, language: WikipediaLanguage) -> URL {
        api(language, [("prop", "langlinks"), ("lllimit", "500"), ("llprop", "autonym|langname"),
                       ("redirects", "1"), ("titles", title)])
    }

    /// The REST summary of an article. The title is assigned raw:
    /// `URLComponents.path` percent-encodes what it is given, so pre-encoding
    /// produced `Ada%2520Lovelace` for "Ada Lovelace" — a path Wikimedia
    /// answers with 403, which every title with a space hit.
    static func summary(title: String, language: WikipediaLanguage) -> URL {
        rest(language, "/api/rest_v1/page/summary/\(title)")
    }

    /// The REST summary of a random article.
    static func random(language: WikipediaLanguage) -> URL {
        rest(language, "/api/rest_v1/page/random/summary")
    }

    /// The featured feed for a day, the date always Gregorian
    /// (``WikipediaText/featuredPath(for:)``).
    static func featured(date: Date, language: WikipediaLanguage) -> URL {
        rest(language, "/api/rest_v1/feed/featured/\(WikipediaText.featuredPath(for: date))")
    }

    /// One kind of anniversary for a day of the year.
    static func onThisDay(type: WikipediaEventType, month: Int, day: Int, language: WikipediaLanguage) -> URL {
        rest(language, String(format: "/api/rest_v1/feed/onthisday/%@/%02d/%02d", type.rawValue, month, day))
    }

    /// The whole daily feed — the featured article and every other section.
    static func dailyFeed(date: Date, language: WikipediaLanguage) -> URL {
        featured(date: date, language: language)
    }

    /// Articles about places within `radius` metres of a point.
    static func nearby(latitude: Double, longitude: Double, radius: Int, limit: Int, language: WikipediaLanguage) -> URL {
        api(language, [("list", "geosearch"), ("gscoord", "\(latitude)|\(longitude)"), ("gsradius", String(radius)),
                       ("gslimit", String(limit))])
    }

    /// An article's primary coordinates.
    static func coordinates(title: String, language: WikipediaLanguage) -> URL {
        api(language, [("prop", "coordinates"), ("coprimary", "primary"), ("redirects", "1"), ("titles", title)])
    }

    /// Title suggestions for a prefix (`opensearch`, main namespace only).
    static func suggestions(prefix: String, limit: Int, language: WikipediaLanguage) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/w/api.php"
        components.queryItems = [URLQueryItem(name: "action", value: "opensearch"), URLQueryItem(name: "search", value: prefix),
                                 URLQueryItem(name: "limit", value: String(limit)), URLQueryItem(name: "namespace", value: "0"),
                                 URLQueryItem(name: "redirects", value: "resolve"), URLQueryItem(name: "format", value: "json")]
        return components.url!
    }

    /// An article's Wikidata item (`pageprops`).
    static func wikidataItem(title: String, language: WikipediaLanguage) -> URL {
        api(language, [("prop", "pageprops"), ("ppprop", "wikibase_item"), ("redirects", "1"), ("titles", title)])
    }

    /// An article's visible categories (hidden maintenance ones excluded),
    /// continuing from `cursor` when the list runs past one page.
    static func categories(title: String, cursor: String?, language: WikipediaLanguage) -> URL {
        api(language, [("prop", "categories"), ("clshow", "!hidden"), ("cllimit", "max"), ("redirects", "1"), ("titles", title)]
                      + (cursor.map { [("clcontinue", $0)] } ?? []))
    }

    /// The images, video and sound an article uses.
    static func media(title: String, language: WikipediaLanguage) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.percentEncodedPath = "/api/rest_v1/page/media-list/" + WikipediaFormat.pageViewsTitle(title)
        return components.url!
    }

    /// Daily human views of an article on all platforms, from Wikimedia's pageviews API.
    static func pageViews(title: String, from start: Date, to end: Date, language: WikipediaLanguage) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "wikimedia.org"
        components.percentEncodedPath = "/api/rest_v1/metrics/pageviews/per-article/\(language.code).wikipedia/all-access/user/"
            + WikipediaFormat.pageViewsTitle(title)
            + "/daily/\(WikipediaFormat.pageViewsDay(start))/\(WikipediaFormat.pageViewsDay(end))"
        return components.url!
    }

    /// Wikimedia's site matrix: every language and its wikis.
    static func siteMatrix() -> URL {
        URL(string: "https://meta.wikimedia.org/w/api.php?action=sitematrix&smtype=language&smlangprop=code%7Cname%7Clocalname%7Csite&smsiteprop=code%7Curl&format=json")!
    }

    /// Where to read an article: `https://<code>.wikipedia.org/wiki/<Title_With_Underscores>`,
    /// the form Wikipedia's own links use.
    static func article(title: String, languageCode: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(languageCode).wikipedia.org"
        components.path = "/wiki/\(title.replacingOccurrences(of: " ", with: "_"))"
        return components.url
    }

    private static func api(_ language: WikipediaLanguage, _ items: [(String, String)]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/w/api.php"
        components.queryItems = [URLQueryItem(name: "action", value: "query"), URLQueryItem(name: "format", value: "json")]
            + items.map { URLQueryItem(name: $0.0, value: $0.1) }
        return components.url!
    }

    private static func rest(_ language: WikipediaLanguage, _ path: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = path
        return components.url!
    }
}
