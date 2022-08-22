//
//  File.swift
//
//
//  Created by Nicholas Trienens on 8/22/22.
//

import Foundation

public extension Array where Element == TrackPoint {
    func averageSpeedSince(startDate: Date) -> Double {
        filter { $0.timestamp > startDate }
            .map(\.speed)
            .average
    }
}

public extension Array where Element == Double {
    /// The average value of all the items in the array
    var average: Double {
        if isEmpty {
            return 0.0
        } else {
            let sum = reduce(0.0, +)
            return Double(sum) / Double(count)
        }
    }
}
