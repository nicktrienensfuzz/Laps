//
// Number+Currency.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency

    return formatter
}()

public extension Int {
    /// Convert an `Int` representing a cost in cents to a currency string. For instance, 303 to $3.03.
    ///
    /// - Returns: A currency string if the `Int` was converted successfully. Otherwise, nil.
    var asCurrency: String? {
        currencyFormatter.string(from: (Double(self) / 100.0) as NSNumber)
    }
}

public extension Float {
    /// Convert an `Float` representing a cost in cents to a currency string. For instance, 3.03 to $3.03.
    ///
    /// - Returns: A currency string if the `Float` was converted successfully. Otherwise, nil.
    var asCurrency: String? {
        currencyFormatter.string(from: Double(self) as NSNumber)
    }
}

public extension Double {
    /// Convert an `Double` representing a cost in cents to a currency string. For instance, 3.03 to $3.03.
    ///
    /// - Returns: A currency string if the `Double` was converted successfully. Otherwise, nil.
    var asCurrency: String? {
        currencyFormatter.string(from: Double(self) as NSNumber)
    }
}
