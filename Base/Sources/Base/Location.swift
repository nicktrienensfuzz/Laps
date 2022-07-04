//
//  File.swift
//
//
//  Created by Nicholas Trienens on 6/20/22.
//

import AsyncLocationKit
import Combine
import CoreLocation
import DependencyContainer
import Foundation
import FuzzCombine
import GRDB

public extension ContainerKeys {
    static let location = KeyedDependency("Location", type: Location.self)

    static func start() {
        DependencyContainer.register(Location(), key: ContainerKeys.location)
        DependencyContainer.register(AppDatabase(), key: ContainerKeys.database)
        DependencyContainer.register(Music(), key: ContainerKeys.music)
    }
}

public class Location {
    public static let shared = Location()
    private let locationManager = CLLocationManager()
    let del: LocationDelegate

    public var location = Reference<CLLocation?>(value: nil)
    public var track = Reference<Track?>(value: nil)

    public func points() -> AnyPublisher<[TrackPoint], Never> {
        track.didUpdate
            .flatMap { track -> AnyPublisher<[TrackPoint], Never> in
                let query: QueryInterfaceRequest<TrackPoint>
                if let track = track {
                    query = TrackPoint.filter(sql: "trackId = '\(track.id)'")
                } else {
                    query = TrackPoint.all()
                }
                var first = true
                return try! DependencyContainer.resolve(key: ContainerKeys.database)
                    .observeAll(query)
                    .catch { error -> AnyPublisher<[TrackPoint], Never> in
                        osLog(error)
                        return Just.any([TrackPoint]())
                    }
                    .map { value -> [TrackPoint] in
                        if first {
                            first = false
                            osLog(value.count)
                        }
                        return value
                    }
                    // .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public init() {
        del = LocationDelegate(location: location, track: track)
        locationManager.startUpdatingLocation()
        // locationManager.startMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = true

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.fitness
        locationManager.delegate = del
    }

    let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)

    public func request() async throws {
        let permission = await asyncLocationManager.requestAuthorizationAlways()
        switch permission {
        case .notDetermined:
            osLog("notDetermined")

        case .restricted:
            osLog("restricted")

        case .denied:
            osLog("denied")

        case .authorizedAlways:
            osLog("authorizedAlways")

        case .authorizedWhenInUse:
            osLog("authorizedWhenInUse")

        case .authorized:
            osLog("authorized")
        default:
            osLog("authorized")
        }
    }

    public func startUpdatingLocation() async -> LocationStream {
        await asyncLocationManager.startUpdatingLocation()
    }

    public func monitorRegionAtLocation(center: CLLocationCoordinate2D, radius _: Double, identifier: String) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            let region = CLCircularRegion(center: center,
                                          radius: 300,
                                          identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
}

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    let location: Reference<CLLocation?>
    let track: Reference<Track?>

    init(location: Reference<CLLocation?>, track: Reference<Track?>) {
        self.location = location
        self.track = track
        super.init()
        Task {
            track.value = try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db -> Track in
                let track = Track(startTime: Date())
                try track.save(db)

                try? osLog("Tracks:\(Track.fetchCount(db))")
                try? osLog("TrackPoints: \(TrackPoint.fetchCount(db))")

                // try TrackPoint.deleteAll(db)
                return track
            }
        }
    }

    // MARK: - Private

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Hit api to update location
        if let location = locations.last {
            self.location.value = location
            let trackId = track.value?.id ?? "-1"
            Task {
                try? await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                    let point = TrackPoint(latitude: location.coordinate.latitude,
                                           longitude: location.coordinate.longitude,
                                           timestamp: location.timestamp,
                                           trackId: trackId)
                    try point.save(db)
                }
            }
        }
    }

    var triggered = [String]()
    var hasFired = false
    func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
        DispatchQueue(label: "background").sync {
            // if !triggered.contains(region.identifier) {
            if !self.hasFired {
                self.hasFired = true
                osLog("enter:")
                osLog(region)
                // triggered.append(region.identifier)
                Task {
                    await Music.shared.test()
                }
            }
        }
    }

    func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
        osLog("exit:")
        osLog(region)
    }

    func locationManager(_: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        osLog(error)
        osLog(region)
    }
}
