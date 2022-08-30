//
//  ContentView.swift
//  LapsWatch WatchKit Extension
//
//  Created by Nicholas Trienens on 8/25/22.
//

import BaseWatch
import FuzzCombine
import HealthKit
import SwiftUI

struct ContentView: View {
    internal init() {
        heartRate = WorkoutTracking.shared.heartRateValue
        workoutSessionState = WorkoutTracking.shared.workoutSessionState
    }

    @ObservedObject var heartRate: Reference<Double>
    @ObservedObject var workoutSessionState: Reference<HKWorkoutSessionState>
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "heart")
                Text("\(String(format: "%0.0f", heartRate.value))")
            }
            .padding()

            Button {
                if WorkoutTracking.shared.workoutSessionState.value != .running {
                    WorkoutTracking.authorizeHealthKit()
                    WorkoutTracking.shared.startWorkOut()
                } else {
                    WorkoutTracking.shared.stopWorkOut()
                }
            } label: {
                if workoutSessionState.value != .running {
                    Text("Start")
                } else {
                    Text("Stop")
                }
            }
        }
        .onReceive(Comms.shared.actions) { action in
            switch action {
            case .startActivity:
                if WorkoutTracking.shared.workoutSessionState.value != .running {
                    WorkoutTracking.authorizeHealthKit()
                    WorkoutTracking.shared.startWorkOut()
                }
            case .stopActivity:
                if WorkoutTracking.shared.workoutSessionState.value == .running {
                    WorkoutTracking.shared.stopWorkOut()
                }
            default: return
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
