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
import Logger

struct ContentView: View {
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    internal init() {
        heartRate = WorkoutTracking.shared.heartRateValue
        heartRateLastUpdate =  Reference<Date?>(value: nil)
        workoutSessionState = WorkoutTracking.shared.workoutSessionState
    }
    
    @ObservedObject var heartRate: Reference<Double>
    @ObservedObject var heartRateLastUpdate: Reference<Date?>
    @ObservedObject var workoutSessionState: Reference<HKWorkoutSessionState>
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "heart")
                Text("\(String(format: "%0.0f", heartRate.value))")
                if let date = self.heartRateLastUpdate.value {
                    Text(date, style: .relative)
                }
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
        .onAppear(perform: start)
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
    
    func start() {
          startHeartRateQuery(quantityTypeIdentifier: .heartRate)
      }
      
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            // 3
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
        }
        
        // 4
        let query = HKAnchoredObjectQuery(
            type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                                          predicate: devicePredicate,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: updateHandler
        )
        
        query.updateHandler = updateHandler
        
        // 5
        
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        if let sample = samples.first {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            osLog("\(Int(lastHeartRate))) @ \(sample.startDate)")
            
            self.heartRate.value = lastHeartRate
            self.heartRateLastUpdate.value = sample.startDate
            // self.value = Int(lastHeartRate)
            
            Comms.shared.sendMessage(.update, heartRate: lastHeartRate, timestamp: sample.startDate)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
