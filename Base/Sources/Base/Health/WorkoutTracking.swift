import Combine
import CoreLocation
import DependencyContainer
import Drops
import GRDB
import HealthKit
import Logger

public protocol WorkoutTrackingProtocol {
    func authorizeHealthKit() async -> Bool
    func observerHeartRateSamples()
}

public class WorkoutTracking {
    public static let shared = WorkoutTracking()
    public let healthStore = HKHealthStore()
    public var observerQuery: HKObserverQuery?

    public init() {}
}

extension WorkoutTracking: WorkoutTrackingProtocol {
    enum Errors: Error {
        case noData
    }

    public func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    @discardableResult
    public func authorizeHealthKit() async -> Bool {
        if HKHealthStore.isHealthDataAvailable() {
            let infoToRead = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
                HKSeriesType.activitySummaryType(),
                HKSeriesType.workoutRoute(),
                HKSeriesType.workoutType(),
            ])

            let infoToShare = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType(),
            ])
            do {
                let authorized = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                    healthStore.requestAuthorization(toShare: infoToShare, read: infoToRead) { success, error in
                        if success {
                            osLog("Authorization HealthKit success")
                            continuation.resume(returning: true)
                        } else if let error = error {
                            osLog(error)
                            continuation.resume(throwing: error)
                        }
                    }
                }
                return authorized
            } catch {
                osLog("HealthKit not available: \(error)")
                return false
            }

        } else {
            osLog("HealthKit not available")
            return false
        }
    }

    public func readWorkouts() async throws -> [HKWorkout] {
        let cycling = HKQuery.predicateForWorkouts(with: .cycling)

        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: cycling, limit: HKObjectQueryNoLimit, sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { _, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }

                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }

                continuation.resume(returning: samples)
            }))
        }

        guard let workouts = samples as? [HKWorkout] else {
            throw Errors.noData
        }

        return workouts
    }

    func getWorkoutRoute(workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        let byWorkout = HKQuery.predicateForObjects(from: workout)

        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
                                                      predicate: byWorkout,
                                                      anchor: nil,
                                                      limit: HKObjectQueryNoLimit,
                                                      resultsHandler: { _, samples, _, _, error in
                                                          if let hasError = error {
                                                              continuation.resume(throwing: hasError)
                                                              return
                                                          }

                                                          guard let samples = samples else {
                                                              continuation.resume(throwing: Errors.noData)
                                                              return
                                                          }

                                                          continuation.resume(returning: samples)
                                                      }))
        }

        guard let workouts = samples as? [HKWorkoutRoute] else {
            throw Errors.noData
        }
        return workouts
    }

    func getLocationDataForRoute(givenRoute: HKWorkoutRoute) async -> [CLLocation] {
        let locations = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []

            // Create the route query.
            let query = HKWorkoutRouteQuery(route: givenRoute) { _, locationsOrNil, done, errorOrNil in

                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                    return
                }

                guard let currentLocationBatch = locationsOrNil else {
                    osLog("no locations returned")
                    continuation.resume(returning: [])
                    return
                }

                allLocations.append(contentsOf: currentLocationBatch)

                if done {
                    continuation.resume(returning: allLocations)
                }
            }

            healthStore.execute(query)
        }

        return locations
    }

    public func lastReadings() -> AnyPublisher<[HeartRatePoint], Never> {
        try! DependencyContainer.resolve(key: ContainerKeys.database)
            .observeAll(HeartRatePoint.all().order(HeartRatePoint.Columns.timestamp).reversed().limit(100))
            .catch { error -> AnyPublisher<[HeartRatePoint], Never> in
                osLog(error)
                return Just.any([HeartRatePoint]())
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
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
                    let timeStamp = sample.startDate
                    osLog("Heart Rate Sample: \(heartRate) @ \(timeStamp.toFormat("hh:mm:ss a"))")

                    let trackId = Location.shared.track.value?.id
                    Task {
                        try? await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                            let point = HeartRatePoint(
                                timestamp: timeStamp,
                                heartRate: heartRate,
                                trackId: trackId
                            )
                            try point.save(db)
                            // osLog("Saved HeartRate: \(point.toSwift())")
                        }
                    }
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

            completionHandler(results?.first as? HKQuantitySample)
        }

        healthStore.execute(query)
    }
}
