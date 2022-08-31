//
// Double+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

public extension Double {
    /// Round double value to number of places.
    ///
    /// - Parameters:
    ///   - to: number of digits after the '.' to include
    /// - Returns: double, rounded value to the number of places
    func rounded(to places: UInt) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
