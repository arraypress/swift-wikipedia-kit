//
//  WikipediaLanguage.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Supported Wikipedia language editions.
///
/// Represents major Wikipedia language editions with their language codes.
/// Each language edition has independent content and may have different
/// articles available.
public enum WikipediaLanguage: String, CaseIterable, Sendable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    case japanese = "ja"
    case chinese = "zh"
    case arabic = "ar"
    case hindi = "hi"
    case korean = "ko"
    case dutch = "nl"
    case polish = "pl"
    case swedish = "sv"
    case norwegian = "no"
    case danish = "da"
    case finnish = "fi"
    case turkish = "tr"
    case czech = "cs"
    
    /// Human-readable language name in the native language
    public var name: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        case .korean: return "한국어"
        case .dutch: return "Nederlands"
        case .polish: return "Polski"
        case .swedish: return "Svenska"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .finnish: return "Suomi"
        case .turkish: return "Türkçe"
        case .czech: return "Čeština"
        }
    }
    
    /// ISO 639-1 language code
    public var code: String {
        return rawValue
    }
    
    /// English name of the language
    public var englishName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .japanese: return "Japanese"
        case .chinese: return "Chinese"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .korean: return "Korean"
        case .dutch: return "Dutch"
        case .polish: return "Polish"
        case .swedish: return "Swedish"
        case .norwegian: return "Norwegian"
        case .danish: return "Danish"
        case .finnish: return "Finnish"
        case .turkish: return "Turkish"
        case .czech: return "Czech"
        }
    }
    
}
