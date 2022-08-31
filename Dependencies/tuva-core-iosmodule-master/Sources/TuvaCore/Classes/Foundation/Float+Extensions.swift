//
// Float+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

#if os(macOS)
    import AppKit
#endif

#if os(iOS)
    import UIKit
#endif


#if os(iOS) || os(macOS)

public extension CGFloat {
    /// Round float value to number of places.
    ///
    /// - Parameters:
    ///   - to: number of digits after the '.' to include
    /// - Returns: float, rounded value to the number of places
    func rounded(to places: UInt) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
#endif

public extension Float {
    /// Round float value to number of places.
    ///
    /// - Parameters:
    ///   - to: number of digits after the '.' to include
    /// - Returns: float, rounded value to the number of places
    func rounded(to places: UInt) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

