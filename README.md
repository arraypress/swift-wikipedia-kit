# WikipediaKit

A lightweight, modern Swift library for querying Wikipedia with built-in Shortcuts support. Perfect for educational apps, content discovery, and automation workflows.

[![Swift 6.1+](https://img.shields.io/badge/Swift-6.1+-orange.svg)](https://swift.org)
[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS 12.0+](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://developer.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- 🔍 **Article Search** - Find Wikipedia articles with relevance scoring
- 📖 **Article Summaries** - Get comprehensive article overviews with metadata
- 🎲 **Random Articles** - Perfect for daily learning and content discovery
- ⭐ **Featured Articles** - Access Wikipedia's highest quality daily content
- 🌍 **Multi-language Support** - Query 20+ Wikipedia language editions
- 📱 **App Intents Integration** - Built-in support for iOS/macOS Shortcuts
- ⚡ **Modern Swift** - Async/await, Sendable, and Swift 6 ready
- 🛡️ **Comprehensive Error Handling** - User-friendly error messages
- 📊 **Rich Metadata** - Reading time estimates, article categories, and more

## Installation

### Swift Package Manager

Add WikipediaKit to your project using Xcode:

1. **File → Add Package Dependencies**
2. Enter: `https://github.com/arraypress/wikipedia-kit`
3. Select your desired version

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/wikipedia-kit", from: "1.0.0")
]
```

## Quick Start

```swift
import WikipediaKit

// Search for articles
let results = try await WikipediaKit.search("machine learning", limit: 5)
print("Found \(results.count) articles")

// Get a specific article
if let article = try await WikipediaKit.getArticle("Swift (programming language)") {
    print("Title: \(article.title)")
    print("Reading time: \(article.estimatedReadingTime) minutes")
    print("Summary: \(article.extract)")
}

// Get a random article for learning
let randomArticle = try await WikipediaKit.randomArticle()
print("Random discovery: \(randomArticle.title)")

// Get today's featured article
let featured = try await WikipediaKit.featuredArticle()
print("Today's featured: \(featured.title)")
```

## Core API

### Search Articles

```swift
// Basic search
let results = try await WikipediaKit.search("quantum physics")

// Search with options
let results = try await WikipediaKit.search(
    "artificial intelligence",
    language: .english,
    limit: 10
)

// Search multiple languages
let englishResults = try await WikipediaKit.search("Paris", language: .english)
let frenchResults = try await WikipediaKit.search("Paris", language: .french)
```

### Get Articles

```swift
// Get specific article
let article = try await WikipediaKit.getArticle("Albert Einstein")

// Get article in different language
let article = try await WikipediaKit.getArticle("Madrid", language: .spanish)

// Smart search + retrieval
let article = try await WikipediaKit.findArticle("Einstein relativity theory")
```

### Discovery Features

```swift
// Random article for learning
let random = try await WikipediaKit.randomArticle()

// Random article in specific language
let randomSpanish = try await WikipediaKit.randomArticle(language: .spanish)

// Featured article of the day
let featured = try await WikipediaKit.featuredArticle()

// Featured article from specific date
let date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let lastWeekFeatured = try await WikipediaKit.featuredArticle(for: date)
```

### Convenience Methods

```swift
// Get just article titles (great for autocomplete)
let titles = try await WikipediaKit.searchTitles("Nobel Prize", limit: 5)
// Returns: ["Nobel Prize", "Nobel Prize in Physics", ...]

// Smart article finding
if let article = try await WikipediaKit.findArticle("machine learning AI") {
    print("Best match: \(article.title)")
}
```

## Data Models

### WikipediaArticle

```swift
public struct WikipediaArticle {
    public let title: String
    public let extract: String              // Article summary
    public let description: String?         // Short description
    public let thumbnail: WikipediaImage?   // Article image
    public let url: URL                     // Link to full article
    public let pageId: Int                  // Wikipedia page ID
    public let language: WikipediaLanguage  // Language edition
    public let lastModified: Date?          // Last edit date
    
    // Computed properties
    public var estimatedReadingTime: Int    // Minutes to read
    public var lengthCategory: ArticleLengthCategory
    public var hasThumbnail: Bool
}
```

### WikipediaSearchResult

```swift
public struct WikipediaSearchResult {
    public let title: String
    public let snippet: String              // Search result preview
    public let pageId: Int
    public let wordCount: Int               // Full article word count
    public let relevanceScore: Double       // Search relevance (0.0+)
    
    // Computed properties
    public var estimatedReadingTime: Int
    public var isHighlyRelevant: Bool       // relevanceScore >= 1.5
}
```

## Shortcuts Integration

WikipediaKit includes built-in App Intents for seamless Shortcuts integration:

### Available Intents

- **Search Wikipedia** - "Search Wikipedia for [topic]"
- **Get Wikipedia Article** - "Get Wikipedia article about [title]"
- **Random Wikipedia Article** - "Give me a random Wikipedia article"
- **Featured Wikipedia Article** - "What's today's featured article?"
- **Search Wikipedia Titles** - "Find Wikipedia titles for [topic]"

### Example Shortcuts

```
"Hey Siri, search Wikipedia for quantum physics"
→ Returns list of relevant articles

"Hey Siri, random Wikipedia article in Spanish"
→ Perfect for language learning

"Hey Siri, what's today's featured Wikipedia article?"
→ Great for daily learning routines

"Hey Siri, get Wikipedia article about Swift programming"
→ Returns detailed article summary
```

### Programmatic Intent Usage

```swift
import WikipediaKit

// Create intents programmatically
let searchIntent = SearchWikipediaIntent(
    query: "machine learning",
    language: .english,
    limit: 5
)

let randomIntent = RandomWikipediaArticleIntent(language: .french)
let articleIntent = GetWikipediaArticleIntent(title: "Swift (programming language)")
```

## Language Support

WikipediaKit supports 20+ major Wikipedia language editions:

```swift
public enum WikipediaLanguage {
    case english, spanish, french, german, italian, portuguese
    case russian, japanese, chinese, arabic, hindi, korean
    case dutch, polish, swedish, norwegian, danish, finnish
    case turkish, czech
    // ... and more
}

// Language properties
print(WikipediaLanguage.spanish.name)        // "Español"
print(WikipediaLanguage.spanish.englishName) // "Spanish"
print(WikipediaLanguage.spanish.code)        // "es"
```

## Error Handling

WikipediaKit provides comprehensive error handling with user-friendly messages:

```swift
do {
    let article = try await WikipediaKit.getArticle("Nonexistent Article")
} catch WikipediaError.articleNotFound(let title) {
    print("Article '\(title)' not found")
} catch WikipediaError.networkError(let message) {
    print("Network error: \(message)")
} catch WikipediaError.rateLimited {
    print("Please wait before making more requests")
} catch WikipediaError.invalidQuery(let query) {
    print("Invalid search: \(query)")
} catch {
    print("Unexpected error: \(error)")
}

// User-friendly error messages
if let wikipediaError = error as? WikipediaError {
    showAlert(message: wikipediaError.userFriendlyDescription)
}
```

## Real-World Examples

### Daily Learning App

```swift
func getDailyLearningContent() async throws -> WikipediaArticle {
    // Try featured article first, fallback to random
    do {
        return try await WikipediaKit.featuredArticle()
    } catch {
        return try await WikipediaKit.randomArticle()
    }
}

func createLearningSession() async throws {
    let article = try await getDailyLearningContent()
    
    print("Today's learning: \(article.title)")
    print("Estimated reading time: \(article.estimatedReadingTime) minutes")
    print("Category: \(article.lengthCategory.description)")
    
    if let thumbnail = article.thumbnail {
        print("Has image: \(thumbnail.source)")
    }
}
```

### Research Assistant

```swift
func researchTopic(_ topic: String, language: WikipediaLanguage = .english) async throws -> ResearchResult {
    // Get main article
    let mainArticle = try await WikipediaKit.findArticle(topic, language: language)
    
    // Get related articles
    let relatedResults = try await WikipediaKit.search(topic, language: language, limit: 10)
    
    // Get additional context
    let relatedArticles = try await withTaskGroup(of: WikipediaArticle?.self) { group in
        for result in relatedResults.prefix(5) {
            group.addTask {
                try? await WikipediaKit.getArticle(result.title, language: language)
            }
        }
        
        var articles: [WikipediaArticle] = []
        for await article in group {
            if let article = article {
                articles.append(article)
            }
        }
        return articles
    }
    
    return ResearchResult(
        mainArticle: mainArticle,
        relatedArticles: relatedArticles,
        searchResults: relatedResults
    )
}
```

### Language Learning

```swift
func createLanguageLearningSession(targetLanguage: WikipediaLanguage) async throws -> LanguageSession {
    // Get random article in target language
    let targetArticle = try await WikipediaKit.randomArticle(language: targetLanguage)
    
    // Get English version for comparison (if available)
    let englishArticle = try? await WikipediaKit.getArticle(targetArticle.title, language: .english)
    
    return LanguageSession(
        targetLanguageArticle: targetArticle,
        referenceArticle: englishArticle,
        estimatedDifficulty: targetArticle.lengthCategory,
        hasVisualAid: targetArticle.hasThumbnail
    )
}
```

### Content Curation

```swift
func curateEducationalContent(topics: [String]) async throws -> [WikipediaArticle] {
    var curatedContent: [WikipediaArticle] = []
    
    for topic in topics {
        // Find best article for each topic
        if let article = try await WikipediaKit.findArticle(topic) {
            // Only include substantial articles
            if article.lengthCategory != .stub && article.estimatedReadingTime >= 2 {
                curatedContent.append(article)
            }
        }
    }
    
    // Sort by reading time for learning progression
    return curatedContent.sorted { $0.estimatedReadingTime < $1.estimatedReadingTime }
}
```

## Article Metadata

WikipediaKit provides rich metadata for educational and content applications:

### Reading Time Estimation

```swift
let article = try await WikipediaKit.getArticle("Machine Learning")!

print("Reading time: \(article.estimatedReadingTime) minutes")
// Based on ~200 words per minute

print("Length category: \(article.lengthCategory.description)")
// "Medium Article", "Long Article", etc.

print("Time range: \(article.lengthCategory.readingTimeRange)")
// 3...5 minutes for long articles
```

### Article Classification

```swift
let article = try await WikipediaKit.getArticle("Swift (programming language)")!

switch article.lengthCategory {
case .stub:
    print("Very brief article (< 50 words)")
case .short:
    print("Short article (50-200 words)")
case .medium:
    print("Medium article (200-500 words)")
case .long:
    print("Long article (500-1,000 words)")
case .veryLong:
    print("Very long article (1,000+ words)")
}
```

### Image Information

```swift
if let thumbnail = article.thumbnail {
    print("Image URL: \(thumbnail.source)")
    print("Dimensions: \(thumbnail.width)x\(thumbnail.height)")
    print("Aspect ratio: \(thumbnail.aspectRatio)")
    
    if thumbnail.isLandscape {
        print("Landscape orientation")
    } else if thumbnail.isPortrait {
        print("Portrait orientation")
    } else {
        print("Square image")
    }
}
```

## Best Practices

### Rate Limiting

Wikipedia has usage guidelines. For high-volume applications:

```swift
// Add delays between requests
for query in queries {
    let results = try await WikipediaKit.search(query)
    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
}

// Use batch operations when possible
let titles = try await WikipediaKit.searchTitles("Physics", limit: 10)
// Better than 10 separate searches
```

### Error Recovery

```swift
func robustArticleRetrieval(title: String) async -> WikipediaArticle? {
    do {
        // Try exact title first
        if let article = try await WikipediaKit.getArticle(title) {
            return article
        }
        
        // Fallback to search
        return try await WikipediaKit.findArticle(title)
        
    } catch WikipediaError.rateLimited {
        // Wait and retry
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        return try? await WikipediaKit.findArticle(title)
        
    } catch WikipediaError.networkError {
        // Handle network issues gracefully
        print("Network unavailable, using cached content")
        return nil
        
    } catch {
        print("Unexpected error: \(error)")
        return nil
    }
}
```

### Performance Optimization

```swift
// Concurrent searches for better performance
func searchMultipleTopics(_ topics: [String]) async -> [String: [WikipediaSearchResult]] {
    await withTaskGroup(of: (String, [WikipediaSearchResult]).self) { group in
        for topic in topics {
            group.addTask {
                let results = try? await WikipediaKit.search(topic, limit: 3)
                return (topic, results ?? [])
            }
        }
        
        var resultDict: [String: [WikipediaSearchResult]] = [:]
        for await (topic, results) in group {
            resultDict[topic] = results
        }
        return resultDict
    }
}
```

## Requirements

- **iOS 15.0+** / **macOS 12.0+** / **tvOS 15.0+** / **watchOS 8.0+**
- **Swift 6.1+**
- **Xcode 16.0+**

## Why Wikipedia Integration Matters

Wikipedia is the world's largest encyclopedia with:
- **60+ million articles** across 300+ languages
- **Billions of monthly readers** worldwide
- **High-quality, curated content** maintained by experts
- **Free, open access** with proper attribution
- **Rich multimedia content** including images and references
- **Constantly updated** with latest information

Perfect for:
- **Educational apps** - Instant access to reliable information
- **Language learning** - Content in dozens of languages
- **Content discovery** - Endless learning possibilities
- **Research tools** - Comprehensive topic coverage
- **Daily learning** - Featured and random content
- **Automation workflows** - Rich Shortcuts integration

## API Rate Limits

WikipediaKit respects Wikipedia's usage guidelines:
- **No authentication required** for basic usage
- **Reasonable request rates** - avoid overwhelming servers
- **Proper User-Agent** headers included automatically
- **Error handling** for rate limit responses
- **Caching recommended** for production applications

For high-volume usage, consider implementing caching or contact Wikipedia about API usage guidelines.

## Contributing

We welcome contributions! Please:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Add tests** for new functionality
4. **Ensure all tests pass** (`swift test`)
5. **Update documentation** as needed
6. **Submit a pull request**

### Development Setup

```bash
git clone https://github.com/arraypress/wikipedia-kit.git
cd wikipedia-kit
swift test
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test class
swift test --filter WikipediaKitTests

# Run with verbose output
swift test --verbose
```

## License

WikipediaKit is available under the MIT License. See [LICENSE](LICENSE) for details.

## Attribution

This library uses Wikipedia's public APIs. Please ensure proper attribution to Wikipedia when using content in your applications:

```
Content from Wikipedia (https://wikipedia.org)
Licensed under CC BY-SA 3.0
```

## Credits

- **Wikipedia** - For providing free, open access to human knowledge
- **Wikimedia Foundation** - For maintaining the infrastructure
- **Wikipedia Community** - For creating and curating content

---

**Built with ❤️ for education, learning, and knowledge sharing**
