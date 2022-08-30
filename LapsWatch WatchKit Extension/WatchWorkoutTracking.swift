//
//  WatchWorkoutTracking.swift
//  ElecDemo WatchKit Extension
//
//  Created by NhatHM on 8/12/19.
//  Copyright © 2019 GST.PID. All rights reserved.
//

import BaseWatch
import Foundation
import FuzzCombine
import HealthKit
import Logger

protocol WorkoutTrackingDelegate: AnyObject {
    func didReceiveHealthKitHeartRate(_ heartRate: Double)
    func didReceiveHealthKitStepCounts(_ stepCounts: Double)
}

protocol WorkoutTrackingProtocol {
    static func authorizeHealthKit()
    func startWorkOut()
    func stopWorkOut()
    func fetchStepCounts()
}

class WorkoutTracking: NSObject {
    static let shared = WorkoutTracking()
    let healthStore = HKHealthStore()
    let configuration = HKWorkoutConfiguration()
    var workoutSession: HKWorkoutSession!
    var workoutBuilder: HKLiveWorkoutBuilder!

    let heartRateValue: Reference<Double> = .init(value: 0)
    let workoutSessionState: Reference<HKWorkoutSessionState> = .init(value: .notStarted)

    weak var delegate: WorkoutTrackingDelegate?

    override init() {
        super.init()
    }

    private func handleSendStatisticsData(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
            let roundedValue = Double(round(1 * value!) / 1)
            heartRateValue.update(value: roundedValue)
            osLog("\(statistics.startDate) \(roundedValue)")

            Comms.shared.sendMessage(Comms.Action.startActivity, heartRate: roundedValue, timestamp: Date())
            delegate?.didReceiveHealthKitHeartRate(roundedValue)

        case HKQuantityType.quantityType(forIdentifier: .stepCount):
            guard let stepCounts = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                return
            }
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepCounts, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
                guard let weakSelf = self else {
                    return
                }
                var resultCount = 0.0
                guard let result = result else {
                    osLog("Failed to fetch steps rate")
                    return
                }

                if let sum = result.sumQuantity() {
                    resultCount = sum.doubleValue(for: HKUnit.count())
                    weakSelf.delegate?.didReceiveHealthKitStepCounts(resultCount)
                } else {
                    osLog("Failed to fetch steps rate 2")
                }
            }
            healthStore.execute(query)
            return
        default:
            return
        }
    }

    private func configWorkout() {
        configuration.activityType = .cycling

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
        } catch {
            workoutSessionState.value = .notStarted
            return
        }

        workoutSession.delegate = self
        workoutBuilder.delegate = self

        workoutBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
    }
}

extension WorkoutTracking: WorkoutTrackingProtocol {
    static func authorizeHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            let infoToRead = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
                HKSampleType.activitySummaryType(),
            ])

            let infoToShare = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
            ])

            HKHealthStore().requestAuthorization(toShare: infoToShare, read: infoToRead) { success, error in
                if success {
                    osLog("Authorization healthKit success")
                } else if let error = error {
                    osLog(error)
                }
            }
        } else {
            osLog("HealthKit not available")
        }
    }

    func startWorkOut() {
        osLog("Start workout")
        configWorkout()
        workoutSession.startActivity(with: Date())
        workoutBuilder.beginCollection(withStart: Date()) { success, error in
            osLog(success)
            if let error = error {
                osLog(error)
            }
        }
    }

    func stopWorkOut() {
        osLog("Stop workout")
        osLog(workoutSessionState.value.title)
        workoutSession.stopActivity(with: Date())
        workoutSession.end()
        workoutBuilder.endCollection(withEnd: Date()) { _, _ in
        }
    }

    func fetchStepCounts() {
        guard let stepCounts = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepCounts, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let weakSelf = self else {
                return
            }
            var resultCount = 0.0
            guard let result = result else {
                osLog("Failed to fetch steps rate")
                return
            }

            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
                weakSelf.delegate?.didReceiveHealthKitStepCounts(resultCount)
            } else {
                osLog("Failed to fetch steps rate 2")
            }
        }
        healthStore.execute(query)
    }
}

extension WorkoutTracking: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // osLog("GET DATA: \(Date())")
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            if let statistics = workoutBuilder.statistics(for: quantityType) {
                handleSendStatisticsData(statistics)
            }
        }
    }

    func workoutBuilderDidCollectEvent(_: HKLiveWorkoutBuilder) {}
}

extension WorkoutTracking: HKWorkoutSessionDelegate {
    func workoutSession(_: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from _: HKWorkoutSessionState, date _: Date)
    {
        osLog(toState.title)
        workoutSessionState.value = toState
    }

    func workoutSession(_: HKWorkoutSession, didFailWithError error: Error) {
        osLog(error)
    }
}

extension HKWorkoutSessionState {
    var title: String {
        switch self {
        case .notStarted:
            return "notStarted"
        case .running:
            return "running"
        case .ended:
            return "ended"
        case .paused:
            return "paused"
        case .prepared:
            return "prepared"
        case .stopped:
            return "stopped"
        @unknown default:
            return "@unknown"
        }
    }
}
