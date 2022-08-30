//
//  Location.swift
//
//
//  Created by Nicholas Trienens on 6/20/22.
//
#if canImport(AsyncLocationKit)

    import AsyncLocationKit
    import Combine
    import CoreLocation
    import DependencyContainer
    import Drops
    import Foundation
    import FuzzCombine
    import GRDB
    import Logger
    import MapKit

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

        let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)
        public private(set) var isMonitoringSignificantLocation: Bool = false
        public private(set) var isTracking: Reference<Bool> = .init(value: false)

        public func circularRegions() -> AnyPublisher<[CircularPOI], Never> {
            try! DependencyContainer.resolve(key: ContainerKeys.database)
                .observeAll(CircularPOI.all())
                .catch { error -> AnyPublisher<[CircularPOI], Never> in
                    osLog(error)
                    return Just.any([CircularPOI]())
                }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }

        public func tracks() -> AnyPublisher<[Track], Never> {
            try! DependencyContainer.resolve(key: ContainerKeys.database)
                .observeAll(Track.all().order(Track.Columns.startTime).reversed().limit(10))
                .catch { error -> AnyPublisher<[Track], Never> in
                    osLog(error)
                    return Just.any([Track]())
                }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }

        public func regions() -> AnyPublisher<[CircularPOI], Never> {
            try! DependencyContainer.resolve(key: ContainerKeys.database)
                .observeAll(CircularPOI.all().order(CircularPOI.Columns.radius).reversed())
                .catch { error -> AnyPublisher<[CircularPOI], Never> in
                    osLog(error)
                    return Just.any([CircularPOI]())
                }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }

        public func points() -> AnyPublisher<[TrackPoint], Never> {
            track.didUpdate
                .prepend(track.value)
                .flatMap { track -> AnyPublisher<[TrackPoint], Never> in
                    let query: QueryInterfaceRequest<TrackPoint>
                    if let track = track {
                        query = TrackPoint.filter(sql: "trackId = '\(track.id)'")
                    } else {
                        query = TrackPoint.all()
                    }
                    // var first = true
                    return try! DependencyContainer.resolve(key: ContainerKeys.database)
                        .observeAll(query)
                        .catch { error -> AnyPublisher<[TrackPoint], Never> in
                            osLog(error)
                            return Just.any([TrackPoint]())
                        }
                        .map { value -> [TrackPoint] in
//                        if first {
//                            first = false
//                            osLog(value.count)
//                        }
                            value
                        }
                        // .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        public init() {
            del = LocationDelegate(location: location, track: track, isTracking: isTracking)
            locationManager.startUpdatingLocation()
            // locationManager.startMonitoringVisits()
            // locationManager.startMonitoringSignificantLocationChanges()
            // locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true

            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = CLActivityType.fitness
            locationManager.delegate = del

            Task {
                do {
                    try await request()
                } catch {
                    osLog(error)
                }
            }
        }

        public func updateIsTracking(_ tracking: Bool) {
            isTracking.value = tracking
        }

        public func startMonitoringSignificantLocationChanges() {
            locationManager.startMonitoringSignificantLocationChanges()
            isMonitoringSignificantLocation = true
        }

        public func stopMonitoringSignificantLocationChanges() {
            locationManager.stopMonitoringSignificantLocationChanges()
            isMonitoringSignificantLocation = false
        }

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
            locationManager.delegate = del
        }

        public func monitorRegionAtLocation(center: CLLocationCoordinate2D, radius: Double, identifier: String) {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                // Register the region.
                let region = CLCircularRegion(center: center,
                                              radius: radius,
                                              identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                locationManager.startMonitoring(for: region)
            } else {
                osLog("Error")
            }
        }

        public func stopMonitoringAllRegions() {
            locationManager.monitoredRegions.forEach { r in
                locationManager.stopMonitoring(for: r)
            }
        }

        public func stopMonitoringRegion(region: CLRegion) {
            locationManager.stopMonitoring(for: region)
            Task {
                try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in
                    if let record = try CircularPOI.fetchOne(db, CircularPOI.filter(CircularPOI.Columns.id == region.identifier)) {
                        try record.delete(db)
                    }
                }
            }
        }

        @discardableResult
        public func allRegions() -> Set<CLRegion> {
//            Task {
//                for r in locationManager.monitoredRegions {
//                    osLog(r)
//
//                    if let record = try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write({ db -> CircularPOI? in
//                        try CircularPOI.fetchOne(db, CircularPOI.filter(CircularPOI.Columns.id == r.identifier))
//                    }) {
//                        self.locationManager.startMonitoring(for: r)
//                    } else {
//                        self.locationManager.stopMonitoring(for: r)
//                    }
//                }
//
//                let trackedIds = self.locationManager.monitoredRegions.map(\.identifier)
//                try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in
//                    let deadRegions = try CircularPOI.fetchAll(db).filter { region in
//                        !trackedIds.contains(region.id)
//                    }
//                    for region in deadRegions {
//                        osLog("deleting")
//                        try region.delete(db)
//                    }
//                }
//            }
            locationManager.monitoredRegions
        }
    }

    class LocationDelegate: NSObject, CLLocationManagerDelegate {
        let location: Reference<CLLocation?>
        let track: Reference<Track?>
        let isTracking: Reference<Bool>

        init(location: Reference<CLLocation?>, track: Reference<Track?>, isTracking: Reference<Bool>) {
            self.location = location
            self.track = track
            self.isTracking = isTracking
            super.init()
            Task {
                track.value = try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db -> Track in
                    // try CircularPOI.deleteAll(db)
//                if let track = try? Track.fetchOne(db, Track.filter(
//                    Track.Columns.id == "2AA56534-14A7-4DCE-8071-7A907DBAAC02"))
//                {
//                    try? osLog("Track Points: \(TrackPoint.filter(TrackPoint.Columns.trackId == track.id).fetchCount(db))")
//
//                    return track
//                }

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
            if let location = locations.last {
                let previousLocation = self.location.value
                self.location.value = location
                // if track.value?.live == .some(true) {
                if isTracking.value || previousLocation == nil {
                    let trackId = track.value?.id ?? "-1"
                    Task {
                        try? await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                            let point = TrackPoint(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude,
                                elevation: location.altitude,
                                horizontalAccuracy: location.horizontalAccuracy,
                                speed: location.speed,
                                speedAccuracy: location.speedAccuracy,
                                course: location.course,
                                courseAccuracy: location.courseAccuracy,
                                timestamp: location.timestamp,
                                trackId: trackId
                            )
                            try point.save(db)
                            // osLog("saved point")
                            let sql = """
                            Select * from CircularPOI_table
                                ORDER BY ABS(latitude - \(location.coordinate.latitude)) + ABS(longitude - \(location.coordinate.longitude))
                            """
                            let rows: [CircularPOI] = try CircularPOI.fetchAll(db,
                                                                               sql: sql,
                                                                               arguments: [])
                            for closest in rows {
                                let distance = closest.coordinate.distance(from: location.coordinate)
                                if distance < closest.radius {
                                    if closest.enteredAt == nil {
                                        closest.enteredAt = Date()
                                        try closest.save(db)
                                        osLog("Entered \(closest)")
                                        Drops.show(.init(title: "Entered"))
                                        Task {
                                            await Music.shared.test()
                                        }
                                    }
                                } else {
                                    if closest.enteredAt != nil {
                                        closest.enteredAt = nil
                                        try closest.save(db)
                                        osLog("Exited \(closest)")
                                        Drops.show(.init(title: "Exited"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
//
//        var triggered = [String]()
//        var hasFired = false
//        func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
//            signPost()
//            Drops.show(.init(title: "Entered Region"))
//
//            DispatchQueue(label: "background")
//                .sync {
//                    // if !triggered.contains(region.identifier) {
//                    if !self.hasFired {
//                        self.hasFired = true
//                        osLog("enter:")
//                        osLog(region)
//                        // triggered.append(region.identifier)
        ////                    Task {
        ////                        await Music.shared.test()
        ////                    }
//                    }
//                }
//        }
//
//        func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
//            osLog("exit:")
//            osLog(region)
//        }
//
//        func locationManager(_: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//            dump(error)
//            osLog(region)
//            if let region = region {
//                Location.shared.stopMonitoringRegion(region: region)
//            }
//        }
    }

#endif
