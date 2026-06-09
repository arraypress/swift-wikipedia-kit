# Swift Wikipedia Kit

A lightweight, dependency-free Swift library for querying Wikipedia. WikipediaKit wraps Wikipedia's public search and REST summary APIs behind a clean async/await interface, letting you search articles, fetch summaries, pull random or featured articles, and work with rich models — all with no API key required and support for 20 language editions.

## Features

- 🔍 **Full-text search** — `search(_:)` returns ranked `WikipediaSearchResult` values with snippets, word counts, and a relevance score
- 📄 **Article summaries** — `getArticle(_:)` fetches a `WikipediaArticle` with extract, description, thumbnail, page URL, and last-modified date
- 🎲 **Random articles** — `randomArticle()` pulls a fresh article from any language edition for discovery or learning
- ⭐ **Featured articles** — `featuredArticle(for:)` retrieves Wikipedia's daily featured article for any date
- 🏷️ **Title-only search** — `searchTitles(_:)` returns just article titles, ideal for autocomplete
- 🎯 **Best-match lookup** — `findArticle(_:)` tries an exact title then falls back to search to return the single most relevant article
- 🌍 **20 language editions** — `WikipediaLanguage` covers English, Spanish, French, German, Japanese, Chinese, Arabic, and more, with native and English names
- ⏱️ **Reading insights** — articles expose `estimatedReadingTime` and a `lengthCategory` (stub → very long) computed from the extract
- 🖼️ **Image metadata** — `WikipediaImage` provides dimensions plus `aspectRatio`, `isLandscape`, `isPortrait`, and `isSquare`
- 🛡️ **Typed errors** — `WikipediaError` distinguishes network, rate-limit, server, invalid-query, and parse failures, each with a `userFriendlyDescription`
- ⚡ **Modern concurrency** — every API is `async`/`throws`, and all models are `Sendable`

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 6.1+
- Xcode 26.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-wikipedia-kit.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies…** and enter `https://github.com/arraypress/swift-wikipedia-kit`.

## Usage

### Searching for articles

```swift
import WikipediaKit

let results = try await WikipediaKit.search("machine learning", limit: 5)
for result in results {
    print("\(result.title) — score \(result.relevanceScore)")
    print(result.snippet)
}
```

### Fetching an article summary

```swift
import WikipediaKit

if let article = try await WikipediaKit.getArticle("Swift (programming language)") {
    print(article.title)
    print(article.extract)
    print("Reading time: \(article.estimatedReadingTime) min")
    print("Length: \(article.lengthCategory.description)")
} else {
    print("Article not found")
}
```

### Random and featured articles

```swift
import WikipediaKit

let random = try await WikipediaKit.randomArticle()
print("Random: \(random.title)")

let featured = try await WikipediaKit.featuredArticle()
print("Featured today: \(featured.title)")
```

### Title autocomplete and best match

```swift
import WikipediaKit

let titles = try await WikipediaKit.searchTitles("Nobel Prize", limit: 5)

if let best = try await WikipediaKit.findArticle("Einstein relativity") {
    print("Best match: \(best.title)")
}
```

### Other languages

```swift
import WikipediaKit

let article = try await WikipediaKit.getArticle("Albert Einstein", language: .german)
print(article?.title ?? "Not found")
```

### Error handling

```swift
import WikipediaKit

do {
    let results = try await WikipediaKit.search("quantum physics")
    print("Found \(results.count) articles")
} catch let error as WikipediaError {
    print(error.userFriendlyDescription)
}
```

## How It Works

WikipediaKit talks to two of Wikipedia's public endpoints:

1. **Action API** (`/w/api.php`) — used by `search` for full-text results, returning snippets and word counts. Snippets are stripped of HTML and each result is assigned a relevance score weighting title matches above snippet matches.
2. **REST API** (`/api/rest_v1/…`) — used by `getArticle`, `randomArticle`, and `featuredArticle` to retrieve page summaries and the daily featured feed.

Queries and titles are validated and length-clamped before any request, and requests carry a timeout and a descriptive User-Agent. A `404` from the summary endpoint is mapped to `nil` rather than an error, so `getArticle` cleanly signals "not found".

## Models

| Type | Kind | Description |
|------|------|-------------|
| `WikipediaArticle` | struct | Article summary: `title`, `extract`, `description`, `thumbnail`, `url`, `pageId`, `language`, `lastModified`, plus computed `estimatedReadingTime`, `lengthCategory`, `hasThumbnail` |
| `WikipediaSearchResult` | struct | Search hit: `title`, `snippet`, `pageId`, `wordCount`, `relevanceScore`, plus `estimatedReadingTime` and `isHighlyRelevant` |
| `WikipediaImage` | struct | Image: `source`, `width`, `height`, plus `aspectRatio`, `isLandscape`, `isPortrait`, `isSquare` |
| `ArticleLengthCategory` | enum | `stub`, `short`, `medium`, `long`, `veryLong` with descriptions and reading-time ranges |
| `WikipediaLanguage` | enum | 20 supported editions with `code`, native `name`, and `englishName` |
| `WikipediaError` | enum | Typed errors with `errorDescription` and `userFriendlyDescription` |

## Use Cases

- Knowledge and trivia apps surfacing summaries and reading times
- Search-as-you-type article suggestions via `searchTitles`
- "Article of the day" or daily-learning experiences using `randomArticle` / `featuredArticle`
- Enriching content with thumbnails and descriptions across multiple languages

## Testing

```bash
swift test
```

The test suite exercises search, summary, random, featured, language handling, and error cases against the live Wikipedia APIs.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
