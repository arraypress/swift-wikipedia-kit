//
//  WikipediaEventType.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Which anniversaries ``WikipediaKit/onThisDay(month:day:type:language:)`` returns.
public enum WikipediaEventType: String, CaseIterable, Sendable {

    /// Wikipedia's editors' selection.
    case selected

    /// Events.
    case events

    /// Births.
    case births

    /// Deaths.
    case deaths

    /// Holidays and observances.
    case holidays
}
