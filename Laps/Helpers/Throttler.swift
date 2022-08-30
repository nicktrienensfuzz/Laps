//
//  Throttler.swift
//  BlueJayKDS
//
//  Created by Nick Trienens on 2/1/21.
//  Copyright © 2021 Fuzz Productions. All rights reserved.
//

import Foundation

/// Throttles the calls to `function` to a maximun interval of `interval`
/// any calls to the returned function within the `iterval` since the last call will do nothing
/// - Parameters:
///   - interval: interval
///   - function: () -> Void, this function
/// - Returns () -> Void
open class Throttler {
    let interval: Double
    var lastFired: Date = .distantPast // track the last fire time

    public init(interval: Double) {
        self.interval = interval
    }

    public func canPerform() -> Bool {
        guard abs(lastFired.timeIntervalSinceNow) >= interval else {
            return false
        }
        lastFired = Date()
        return true
    }
}
