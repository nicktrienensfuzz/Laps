//
//  HeartRateView.swift
//  Laps
//
//  Created by Nicholas Trienens on 8/29/22.
//

import AVFoundation
import Base
import BaseWatch
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import SwiftUI
import Base
import ComposableArchitecture

struct HeartRateView: View {
    let store: StoreOf<IntervalFeature>

//
//    @State var heartRate = BoundReference<[HeartRatePoint]>(value: [])
//    init() {
//        heartRate.bind(to:
//            WorkoutTracking.shared.lastReadings()
//        )
//    }

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Image(systemName: "heart")
                    .font(.title)
                if let hr = viewStore.heartRate {
                    Text("\(String(format: "%0.0f", viewStore.heartRate?.heartRate ?? 0 ))")
                        .font(.title)
                    Text(hr.timestamp, style: .relative)
                    //Text("\(String(format: "%0.0f", hr.timestamp.timeIntervalToNow ))")
                      //  .font(.body)
                }
                
            }
        }
    }
}

struct HeartRate_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView(store: Store(initialState: IntervalFeature.State(), reducer: IntervalFeature()))
    }
}
