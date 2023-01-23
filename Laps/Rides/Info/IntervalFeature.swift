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


struct IntervalFeature: ReducerProtocol {
    
    struct State: Equatable {
        
        var heartRate: HeartRatePoint?
        var heartRateRecent: [HeartRatePoint] = []
    }
    
    enum Action: Equatable {
        case heartRate(HeartRatePoint)
        case heartRates([HeartRatePoint])
    }
    
//    var heartRate = BoundReference<[HeartRatePoint]>(value: [])
//    init() {
//        heartRate.bind(to: WorkoutTracking.shared.lastReadings())
//        heartRate.onChange { newValue in
//            print(newValue.first)
//        }
//    }
//
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .heartRate(value):
            state.heartRate = value
            
            
        case let .heartRates(value):
            state.heartRateRecent = value
            
        }
        return .none
    }
}
