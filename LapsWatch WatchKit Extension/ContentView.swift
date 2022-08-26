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
            Text("Hello, World!\n\(heartRate.value)")
            .padding()
            
            Button {
                WorkoutTracking.authorizeHealthKit()
                WorkoutTracking.shared.startWorkOut()
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
