//
//  WikipediaError.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Errors that can occur during Wikipedia operations.
///
/// Provides specific error types for different failure scenarios
/// with user-friendly error messages.
public enum WikipediaError: Error, LocalizedError, Sendable {
    
    /// Article or search result not found
    case articleNotFound(String)
    
    /// Network connectivity or HTTP error
    case networkError(String)
    
    /// Invalid search query or parameters
    case invalidQuery(String)
    
    /// Rate limited by Wikipedia servers
    case rateLimited
    
    /// Wikipedia server error (5xx status codes)
    case serverError(Int)
    
    /// Unsupported or invalid language code
    case invalidLanguage(String)
    
    /// Failed to parse response data
    case parseError(String)
    
    public var errorDescription: String? {
        switch self {
        case .articleNotFound(let title):
            return "Article '\(title)' not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidQuery(let query):
            return "Invalid search query: '\(query)'"
        case .rateLimited:
            return "Rate limited - please try again later"
        case .serverError(let code):
            return "Wikipedia server error: \(code)"
        case .invalidLanguage(let lang):
            return "Unsupported language: \(lang)"
        case .parseError(let message):
            return "Failed to parse response: \(message)"
        }
    }
    
    /// User-friendly error message suitable for displaying in UI
    public var userFriendlyDescription: String {
        switch self {
        case .articleNotFound:
            return "Article not found. Try checking the spelling or searching for a similar topic."
        case .networkError:
            return "Unable to connect to Wikipedia. Please check your internet connection."
        case .invalidQuery:
            return "Please enter a valid search term."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .serverError:
            return "Wikipedia is temporarily unavailable. Please try again later."
        case .invalidLanguage:
            return "This language is not supported."
        case .parseError:
            return "Unable to process the response from Wikipedia."
        }
    }
    
}
