//
//  ContentView.swift
//  LapsWatch WatchKit Extension
//
//  Created by Nicholas Trienens on 8/25/22.
//

import SwiftUI
import BaseWatch
import FuzzCombine

struct ContentView: View {
    internal init(){
        heartRate = WorkoutTracking.shared.heartRateValue
    }
    
    @ObservedObject var heartRate: Reference<Double>
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "heart")
                Text("\(String(format: "%0.0f",heartRate.value))")
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
                Text("test")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
