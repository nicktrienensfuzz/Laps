
import HealthKit

public protocol WorkoutTrackingProtocol {
    func authorizeHealthKit()
    func observerHeartRateSamples()
}

public class WorkoutTracking {
    public static let shared = WorkoutTracking()
    public let healthStore = HKHealthStore()
    public var observerQuery: HKObserverQuery?

    public init() {}
}

extension WorkoutTracking: WorkoutTrackingProtocol {
    public func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func authorizeHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            let infoToRead = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
            ])

            let infoToShare = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
            ])

            healthStore.requestAuthorization(toShare: infoToShare, read: infoToRead) { success, error in
                if success {
                    osLog("Authorization HealthKit success")
                } else if let error = error {
                    print(error)
                }
            }
        } else {
            osLog("HealthKit not available")
        }
    }

    public func observerHeartRateSamples() {
        guard let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        if let observerQuery = observerQuery {
            healthStore.stop(observerQuery)
        }

        let newObserverQuery = HKObserverQuery(sampleType: heartRateSampleType, predicate: nil) { [unowned self] _, _, error in
            if let error = error {
                osLog("Error: \(error.localizedDescription)")
                return
            }

            self.fetchLatestHeartRateSample { sample in
                guard let sample = sample else {
                    return
                }

                DispatchQueue.main.async {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    osLog("Heart Rate Sample: \(heartRate)")
                    LocalNotificationHelper.fireHeartRate(heartRate)
                }
            }
        }

        healthStore.execute(newObserverQuery)
        observerQuery = newObserverQuery
        healthStore.enableBackgroundDelivery(for: heartRateSampleType, frequency: .immediate) { success, error in
            osLog(success)
            if let error = error {
                osLog(error)
            }
        }
    }
}

extension WorkoutTracking {
    private func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { _, results, error in
            if let error = error {
                osLog("Error: \(error.localizedDescription)")
                return
            }

            completionHandler(results?[0] as? HKQuantitySample)
        }

        healthStore.execute(query)
    }
}
