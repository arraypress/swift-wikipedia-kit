//
//  WikipediaKit.swift
//  WikipediaKit
//
//  A lightweight Swift library for querying Wikipedia with App Intents support
//  Created on 03/08/2025.
//

import Foundation

// MARK: - Main Public API

/// A lightweight Wikipedia query library for iOS, macOS, and Shortcuts integration.
///
/// WikipediaKit provides a clean, Swift-native interface to Wikipedia's REST API,
/// making it easy to search articles, get summaries, and integrate with the Shortcuts app.
///
/// ## Key Features
///
/// - **Article Search**: Find Wikipedia articles by keyword
/// - **Article Summaries**: Get concise article overviews with metadata
/// - **Random Articles**: Discover content for learning or exploration
/// - **Featured Articles**: Access Wikipedia's daily featured content
/// - **Multi-language Support**: Query in 20+ languages
/// - **App Intents Integration**: Built-in Shortcuts support
/// - **Async/Await**: Modern Swift concurrency
/// - **Error Handling**: Comprehensive error reporting
///
/// ## Basic Usage
///
/// ```swift
/// import WikipediaKit
///
/// // Search for articles
/// let results = try await WikipediaKit.search("quantum physics")
/// print("Found \(results.count) articles")
///
/// // Get article summary
/// let article = try await WikipediaKit.getArticle("Swift (programming language)")
/// print("Title: \(article.title)")
/// print("Summary: \(article.extract)")
///
/// // Random article
/// let random = try await WikipediaKit.randomArticle()
/// print("Random article: \(random.title)")
/// ```
///
/// ## Shortcuts Integration
///
/// WikipediaKit includes built-in App Intents for Shortcuts:
/// - "Search Wikipedia for [topic]"
/// - "Get Wikipedia article [title]"
/// - "Random Wikipedia article"
/// - "Featured Wikipedia article"
///
/// ## Rate Limiting
///
/// This library respects Wikipedia's usage guidelines. For high-volume usage,
/// consider implementing additional caching or rate limiting.
public struct WikipediaKit {
    
    // MARK: - Public Methods
    
    /// Search Wikipedia for articles matching the given query.
    ///
    /// Performs a full-text search across Wikipedia articles and returns
    /// a list of matching results with relevance scoring.
    ///
    /// ## Example
    /// ```swift
    /// let results = try await WikipediaKit.search("machine learning", limit: 5)
    /// for result in results {
    ///     print("\(result.title): \(result.snippet)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - query: Search terms to find articles for
    ///   - language: Wikipedia language edition (default: English)
    ///   - limit: Maximum number of results to return (1-50, default: 10)
    /// - Returns: Array of search results ordered by relevance
    /// - Throws: `WikipediaError` if the search fails or query is invalid
    public static func search(
        _ query: String,
        language: WikipediaLanguage = .english,
        limit: Int = 10
    ) async throws -> [WikipediaSearchResult] {
        try validateSearchQuery(query)
        let clampedLimit = max(1, min(50, limit)) // Clamp between 1-50
        
        let searchURL = buildSearchURL(query: query, language: language, limit: clampedLimit)
        let data = try await performRequest(url: searchURL)
        
        let searchResponse = try JSONDecoder().decode(WikipediaSearchResponse.self, from: data)
        return searchResponse.query.search.map { result in
            WikipediaSearchResult(
                title: result.title,
                snippet: result.snippet.cleanHTML(),
                pageId: result.pageid,
                wordCount: result.wordcount,
                relevanceScore: calculateRelevanceScore(result, for: query)
            )
        }
    }
    
    /// Get a comprehensive summary of a Wikipedia article.
    ///
    /// Retrieves article content including title, extract, images, and metadata.
    /// Returns `nil` if the article doesn't exist.
    ///
    /// ## Example
    /// ```swift
    /// if let article = try await WikipediaKit.getArticle("Artificial Intelligence") {
    ///     print("Title: \(article.title)")
    ///     print("Reading time: \(article.estimatedReadingTime) minutes")
    ///     print("Summary: \(article.extract)")
    /// } else {
    ///     print("Article not found")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: Exact or approximate article title
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: Article summary or `nil` if not found
    /// - Throws: `WikipediaError` for network or parsing errors
    public static func getArticle(
        _ title: String,
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle? {
        try validateArticleTitle(title)
        
        let summaryURL = buildSummaryURL(title: title, language: language)
        
        do {
            let data = try await performRequest(url: summaryURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let summary = try decoder.decode(WikipediaSummaryResponse.self, from: data)
            
            return WikipediaArticle(
                title: summary.title,
                extract: summary.extract,
                description: summary.description,
                thumbnail: summary.thumbnail.flatMap {
                    guard let url = URL(string: $0.source) else { return nil }
                    return WikipediaImage(source: url, width: $0.width, height: $0.height)
                },
                url: summary.content_urls.desktop.page,
                pageId: summary.pageid,
                language: language,
                lastModified: summary.timestamp
            )
        } catch WikipediaError.networkError(let message) where message.contains("404") {
            return nil // Article not found
        }
    }
    
    /// Get a random Wikipedia article for discovery and learning.
    ///
    /// Perfect for educational apps, daily learning routines, or content discovery.
    /// Each call returns a different random article from the specified language edition.
    ///
    /// ## Example
    /// ```swift
    /// let randomArticle = try await WikipediaKit.randomArticle()
    /// print("Today's random learning: \(randomArticle.title)")
    /// print("Category: \(randomArticle.lengthCategory.description)")
    /// ```
    ///
    /// - Parameter language: Wikipedia language edition (default: English)
    /// - Returns: A random Wikipedia article summary
    /// - Throws: `WikipediaError` if the request fails
    public static func randomArticle(
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle {
        let randomURL = buildRandomURL(language: language)
        let data = try await performRequest(url: randomURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let summary = try decoder.decode(WikipediaSummaryResponse.self, from: data)
        
        return WikipediaArticle(
            title: summary.title,
            extract: summary.extract,
            description: summary.description,
            thumbnail: summary.thumbnail.flatMap {
                guard let url = URL(string: $0.source) else { return nil }
                return WikipediaImage(source: url, width: $0.width, height: $0.height)
            },
            url: summary.content_urls.desktop.page,
            pageId: summary.pageid,
            language: language,
            lastModified: summary.timestamp
        )
    }
    
    /// Get Wikipedia's featured article for a specific date.
    ///
    /// Featured articles are Wikipedia's highest quality content, chosen daily
    /// by the Wikipedia community. Perfect for daily learning or content curation.
    ///
    /// ## Example
    /// ```swift
    /// // Today's featured article
    /// let featured = try await WikipediaKit.featuredArticle()
    /// print("Today's featured: \(featured.title)")
    ///
    /// // Featured article from a specific date
    /// let date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    /// let lastWeek = try await WikipediaKit.featuredArticle(for: date)
    /// ```
    ///
    /// - Parameters:
    ///   - date: Date to get featured article for (default: today)
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: The featured article for the specified date
    /// - Throws: `WikipediaError` if no featured article exists for the date
    /// - Note: Featured articles are only available for certain language editions
    public static func featuredArticle(
        for date: Date = Date(),
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle {
        let featuredURL = buildFeaturedURL(date: date, language: language)
        let data = try await performRequest(url: featuredURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let featuredResponse = try decoder.decode(WikipediaFeaturedResponse.self, from: data)
        let summary = featuredResponse.tfa
        
        return WikipediaArticle(
            title: summary.title,
            extract: summary.extract,
            description: summary.description,
            thumbnail: summary.thumbnail.flatMap {
                guard let url = URL(string: $0.source) else { return nil }
                return WikipediaImage(source: url, width: $0.width, height: $0.height)
            },
            url: summary.content_urls.desktop.page,
            pageId: summary.pageid,
            language: language,
            lastModified: summary.timestamp
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Quick search that returns only article titles.
    ///
    /// Useful for autocomplete functionality or when you only need article names.
    ///
    /// ## Example
    /// ```swift
    /// let titles = try await WikipediaKit.searchTitles("Nobel Prize", limit: 5)
    /// // Returns: ["Nobel Prize", "Nobel Prize in Physics", "Nobel Prize in Chemistry", ...]
    /// ```
    ///
    /// - Parameters:
    ///   - query: Search terms
    ///   - language: Wikipedia language edition (default: English)
    ///   - limit: Maximum number of titles (default: 10)
    /// - Returns: Array of article titles
    /// - Throws: `WikipediaError` if the search fails
    public static func searchTitles(
        _ query: String,
        language: WikipediaLanguage = .english,
        limit: Int = 10
    ) async throws -> [String] {
        let results = try await search(query, language: language, limit: limit)
        return results.map { $0.title }
    }
    
    /// Search for an article and return the best match.
    ///
    /// Combines search and article retrieval to find the most relevant article
    /// for a query. Useful when you want a single, best result rather than a list.
    ///
    /// ## Example
    /// ```swift
    /// if let article = try await WikipediaKit.findArticle("Einstein relativity") {
    ///     print("Best match: \(article.title)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - query: Search terms or article title
    ///   - language: Wikipedia language edition (default: English)
    /// - Returns: Best matching article or `nil` if none found
    /// - Throws: `WikipediaError` if the search fails
    public static func findArticle(
        _ query: String,
        language: WikipediaLanguage = .english
    ) async throws -> WikipediaArticle? {
        // Try exact title match first
        if let exactMatch = try await getArticle(query, language: language) {
            return exactMatch
        }
        
        // Fall back to search
        let searchResults = try await search(query, language: language, limit: 1)
        guard let firstResult = searchResults.first else { return nil }
        
        return try await getArticle(firstResult.title, language: language)
    }
}

// MARK: - Internal Implementation

extension WikipediaKit {
    
    /// Validates search query for basic requirements
    private static func validateSearchQuery(_ query: String) throws {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw WikipediaError.invalidQuery("Search query cannot be empty")
        }
        guard trimmed.count <= 300 else {
            throw WikipediaError.invalidQuery("Search query too long (max 300 characters)")
        }
    }
    
    /// Validates article title for basic requirements
    private static func validateArticleTitle(_ title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw WikipediaError.invalidQuery("Article title cannot be empty")
        }
        guard trimmed.count <= 255 else {
            throw WikipediaError.invalidQuery("Article title too long (max 255 characters)")
        }
    }
    
    /// Builds URL for article search
    private static func buildSearchURL(query: String, language: WikipediaLanguage, limit: Int) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/w/api.php"
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "list", value: "search"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "srsearch", value: query),
            URLQueryItem(name: "srlimit", value: String(limit)),
            URLQueryItem(name: "srprop", value: "snippet|wordcount")
        ]
        return components.url!
    }
    
    /// Builds URL for article summary
    private static func buildSummaryURL(title: String, language: WikipediaLanguage) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/api/rest_v1/page/summary/\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title)"
        return components.url!
    }
    
    /// Builds URL for random article
    private static func buildRandomURL(language: WikipediaLanguage) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/api/rest_v1/page/random/summary"
        return components.url!
    }
    
    /// Builds URL for featured article
    private static func buildFeaturedURL(date: Date, language: WikipediaLanguage) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: date)
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(language.code).wikipedia.org"
        components.path = "/api/rest_v1/feed/featured/\(dateString)"
        return components.url!
    }
    
    /// Performs HTTP request with proper error handling
    private static func performRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("WikipediaKit/1.0 Swift Educational Library - Test Suite", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.timeoutInterval = 10.0 // Add timeout
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WikipediaError.networkError("Invalid response type")
            }
            
            switch httpResponse.statusCode {
            case 200:
                return data
            case 403:
                throw WikipediaError.rateLimited
            case 404:
                throw WikipediaError.networkError("404 - Not found")
            case 429:
                throw WikipediaError.rateLimited
            case 500...599:
                throw WikipediaError.serverError(httpResponse.statusCode)
            default:
                throw WikipediaError.networkError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as WikipediaError {
            throw error
        } catch {
            throw WikipediaError.networkError(error.localizedDescription)
        }
    }
    
    /// Calculates relevance score for search results
    private static func calculateRelevanceScore(_ result: WikipediaSearchResponseItem, for query: String) -> Double {
        let queryWords = query.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let titleWords = result.title.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let snippetWords = result.snippet.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        var score = 0.0
        
        // Title matches are weighted more heavily
        for queryWord in queryWords {
            if titleWords.contains(queryWord) {
                score += 2.0
            } else if snippetWords.contains(queryWord) {
                score += 1.0
            }
        }
        
        // Normalize by query length
        return score / Double(queryWords.count)
    }
}

// MARK: - String Extensions

private extension String {
    /// Removes HTML tags from Wikipedia snippets
    func cleanHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
