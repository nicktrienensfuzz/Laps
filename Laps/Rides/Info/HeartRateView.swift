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

struct HeartRateView: View {
    @State var heartRate = BoundReference<[HeartRatePoint]>(value: [])
    init() {
        heartRate.bind(to:
            WorkoutTracking.shared.lastReadings()
        )
    }

    var body: some View {
        HStack {
            Image(systemName: "heart")
                .font(.title)
            Text("\(String(format: "%0.0f", heartRate.value.first?.heartRate ?? 0))")
                .font(.title)
        }
    }
}

struct HeartRate_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
    }
}
