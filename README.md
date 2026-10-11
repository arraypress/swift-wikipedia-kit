# Swift Wikipedia Kit

A lightweight, dependency-free Swift library for querying Wikipedia. WikipediaKit wraps Wikipedia's public search and REST summary APIs behind a clean async/await interface, letting you search articles, fetch summaries, pull random or featured articles, and work with rich models — all with no API key required and support for 20 language editions.

## Features

- 🔍 **Full-text search** — `search(_:)` returns ranked `WikipediaSearchResult` values with snippets, word counts, and a relevance score
- 📄 **Article summaries** — `getArticle(_:)` fetches a `WikipediaArticle` with extract, description, thumbnail, page URL, and last-modified date
- 🎲 **Random articles** — `randomArticle()` pulls a fresh article from any language edition for discovery or learning
- ⭐ **Featured articles** — `featuredArticle(for:)` retrieves Wikipedia's daily featured article for any date
- 📚 **Full article text** — `getContent(_:)` returns the whole page as plain text (the summary is only the lead: 448 characters of Alan Turing's 63,928)
- 🌐 **Other languages** — `getTranslations(_:)` lists every language an article exists in, with its title there
- 📰 **The daily feed** — `dailyFeed()` returns Wikipedia's front page for any day: featured article, most read (with views), in the news, picture of the day (with credit and licence), "Did you know…" and anniversaries
- 📅 **On this day** — `onThisDay(month:day:type:)` lists events, births, deaths, holidays, or the editors' selection
- 📍 **Places** — `nearby(latitude:longitude:radius:)` finds articles about places near a point, nearest first; `coordinates(of:)` locates an article's subject
- ⌨️ **Autocomplete** — `suggestions(_:)` uses the API made for typeahead ("alan tur" → Alan Turing, Alan Turing Institute…)
- 🔗 **Wikidata** — `wikidataID(for:)` returns an article's item ID (Alan Turing → `Q7251`)
- 📈 **Page views** — `pageViews(_:from:to:)` gives daily human readership from Wikimedia's pageviews API
- 🖼️ **Media and categories** — `media(of:)` lists every image, video and sound file on a page; `categories(of:)` its visible categories
- 🏷️ **Title-only search** — `searchTitles(_:)` returns just article titles, ideal for autocomplete
- 🎯 **Best-match lookup** — `findArticle(_:)` tries an exact title then falls back to search to return the single most relevant article
- 🌍 **20 language editions** — `WikipediaLanguage` covers English, Spanish, French, German, Japanese, Chinese, Arabic, and more, with native and English names
- ⏱️ **Reading insights** — articles expose `estimatedReadingTime` and a `lengthCategory` (stub → very long) computed from the extract
- 🖼️ **Image metadata** — `WikipediaImage` provides dimensions plus `aspectRatio`, `isLandscape`, `isPortrait`, and `isSquare`
- 🛡️ **Typed errors** — `WikipediaError` distinguishes network, rate-limit, server, invalid-query, and parse failures, each with a `userFriendlyDescription`
- ⚡ **Modern concurrency** — every API is `async`/`throws`, and all models are `Sendable`

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ — Apple platforms only. The
  package also compiles on Linux and Windows (it imports `FoundationNetworking` where
  that exists), but those platforms are not tested or supported.
- Swift 6.1+
- Xcode 26.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-wikipedia-kit.git", from: "1.2.0")
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

### The daily feed and anniversaries

```swift
import WikipediaKit

let feed = try await WikipediaKit.dailyFeed()
for trending in feed.mostRead.prefix(5) {
    print("\(trending.rank). \(trending.article.title) — \(trending.views) views")
}
print(feed.picture?.title ?? "", feed.picture?.license ?? "")

let births = try await WikipediaKit.onThisDay(month: 10, day: 11, type: .births)
```

Sections a language edition does not publish come back empty — of the 20 editions, only English,
German, Japanese, Chinese and Swedish carry a featured article in the feed, and eight have no
"on this day" feed. A day before the feed began (2016) returns an empty feed rather than an error.

### Places

```swift
import WikipediaKit

let around = try await WikipediaKit.nearby(latitude: 48.8584, longitude: 2.2945, radius: 1_000)
let tower = try await WikipediaKit.coordinates(of: "Eiffel Tower")   // nil for people and ideas
```

### More about one article

```swift
import WikipediaKit

let titles = try await WikipediaKit.suggestions("alan tur")              // typeahead
let item = try await WikipediaKit.wikidataID(for: "Alan Turing")          // "Q7251"
let views = try await WikipediaKit.pageViews("Alan Turing", from: lastWeek)
let media = try await WikipediaKit.media(of: "Apollo 11")                 // images, video, audio
let categories = try await WikipediaKit.categories(of: "Alan Turing")     // "1912 births", …
```

Missing things are empty or `nil`, not errors: an article without coordinates, a Wikidata item,
media or page views; a page-views range before July 2015 or in the future. Impossible input is
refused before any request with `WikipediaError.invalidQuery` — 30 February, coordinates off the
globe, a radius outside the API's 10–10,000 m, a range that runs backwards, an empty prefix.

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

1. **Action API** (`/w/api.php`) — used by `search` for full-text results, returning snippets and word counts. Snippets are stripped of HTML and their entities decoded (`&quot;` → `"`), and each result gets a relevance score from 0 to 2: 2 for each query word in the title, 1 for each found only in the snippet, averaged over the query, with punctuation ignored so "Observer (quantum physics)" matches "quantum physics".
2. **REST API** (`/api/rest_v1/…`) — used by `getArticle`, `randomArticle`, and `featuredArticle` to retrieve page summaries and the daily featured feed. The featured feed's date is always sent in the Gregorian calendar, whatever calendar the device uses.

`getContent` and `getTranslations` use the Action API's `extracts` and `langlinks`; `nearby`, `coordinates`, `wikidataID` and `categories` its `geosearch`, `coordinates`, `pageprops` and `categories` (following continuation, hidden categories excluded), and `suggestions` its `opensearch`. The daily feed, on this day and media come from the REST API, and page views from Wikimedia's pageviews API. Articles inside the feed carry their page key as their title ("List_of_equations"); the readable `normalized` title is used instead. Queries and titles are validated and length-clamped before any request, and requests carry a timeout and a User-Agent with a contact URL, as Wikimedia's policy asks. A response in an unexpected shape throws `WikipediaError.parseError`. A `404` from the summary endpoint is mapped to `nil` rather than an error, so `getArticle` cleanly signals "not found".

## Models

| Type | Kind | Description |
|------|------|-------------|
| `WikipediaArticle` | struct | Article summary: `title`, `extract`, `description`, `thumbnail`, `url`, `pageId`, `language`, `lastModified`, plus computed `estimatedReadingTime`, `lengthCategory`, `hasThumbnail` |
| `WikipediaSearchResult` | struct | Search hit: `title`, `snippet`, `pageId`, `wordCount`, `relevanceScore`, plus `estimatedReadingTime` and `isHighlyRelevant` |
| `WikipediaContent` | struct | Full article: `title`, `text`, `pageId`, `language`, `url`, plus `characterCount` and `wordCount` |
| `WikipediaTranslation` | struct | Another language of an article: `code`, `name` (its autonym), `title`, and `url` |
| `WikipediaDailyFeed` | struct | A day's front page: `featured`, `mostRead`, `news`, `picture`, `didYouKnow`, `onThisDay` |
| `WikipediaTrendingArticle` | struct | A most-read article with its `views` and `rank` |
| `WikipediaNewsStory` | struct | An "In the news" story: `text` and the `articles` it links |
| `WikipediaPicture` | struct | Picture of the day: `image`, `thumbnail`, `description`, `artist`, `credit`, `license`, `licenseURL`, `filePage` |
| `WikipediaHistoricalEvent` | struct | An anniversary: `text`, `year` (nil for holidays), `articles` |
| `WikipediaNearbyArticle` | struct | A place's article: `title`, `pageId`, `coordinates`, `distance` in metres |
| `WikipediaCoordinates` | struct | `latitude`, `longitude` |
| `WikipediaDailyViews` | struct | One UTC day's human `views` |
| `WikipediaMediaItem` | struct | A file on a page: `title`, `type` (image/video/audio), `url`, `isLeadImage`, `caption` |
| `WikipediaEventType` | enum | `selected`, `events`, `births`, `deaths`, `holidays` |
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

The live tests exercise every endpoint against Wikipedia's APIs, skipping when Wikimedia refuses (403/429); `WikipediaTextTests` and `WikipediaEndpointTests` check the text, URL, validation, format and decoding helpers offline, including a daily feed with sections missing. Every call was also run live against all 20 language editions.

Sources are laid out as `Core/` (the client and the API's JSON shapes), `Models/`, `Enums/`, `Errors/`, `Extensions/` (thin computed properties) and `Support/` (pure functions: URLs, text cleaning, relevance, reading figures, decoding).

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
