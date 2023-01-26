//
//  IntervalFeature.swift
//  Laps
//
//  Created by Nicholas Trienens on 1/20/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import FuzzCombine
import Base
import Logger

struct IntervalFeature: ReducerProtocol {
    
    struct State: Equatable {
        
        var heartRate: HeartRatePoint?
        var heartRateRecent: [HeartRatePoint] = []
    }
    
    enum Action: Equatable {
        case heartRates([HeartRatePoint])
        case checkTrend
    }

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .checkTrend:
            let heartRateRecent = state.heartRateRecent
            return .run { _ in
                checkTrend(heartRateRecent)
                
            }
            
        case let .heartRates(value):
            state.heartRateRecent = value
            state.heartRate = value.first
            return .task { .checkTrend }
        }
        return .none
    }
    
    let throttle = Throttler(interval: 15.0)
    let announce = Announcer()
    func checkTrend(_ recentReadings: [HeartRatePoint]) {
        if recentReadings.count >= 20  {
            // let trend = [286.0, 305.0, 305.0, 305.0]
            let trend =            recentReadings
                .map{ $0.heartRate }
                .chunked(into: 5)
                .map {  $0.reduce(0, +) }
                print(trend)
            if trend.detectConsistentDecline() {
                if throttle.canPerform() {
                    osLog("speak")
                    DispatchQueue.main.async {
                        announce.speak("heartRate dropping")
                    }
                }
            }
        }
        
    }
}


extension Array where Element: Comparable {
    
    func detectConsistentDecline(steps: Int = 3) -> Bool {
        if let start = first {
            for i in 1...steps {
                if start > self[i] {
                    return false
                }
            }
            return true
        }
        return false
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
