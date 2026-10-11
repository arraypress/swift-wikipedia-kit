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
