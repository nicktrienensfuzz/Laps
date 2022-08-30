//
//  TrackPoint+Extensions.swift
//
//
//  Created by Nicholas Trienens on 8/22/22.
//

import CoreLocation
import Foundation
import Logger
import MapKit

public extension Array where Element == TrackPoint {
    func region() -> MKCoordinateRegion {
        MKCoordinateRegion(coordinates: self)
    }

    func speedLast() -> Double {
        takeFirst(2)
            .computeDistance()
    }

    func averageSpeedSince(startDate: Date) -> Double {
        filter { $0.timestamp > startDate }
            .computeDistance()
    }

    func computeDistance() -> Double {
        guard let first = first else { return 0.0 }
        guard let last = last, first != last else { return 0.0 }

        var prevPoint = first
        let distanceTraveled = reduce(0.0) { count, point -> Double in
            let newCount = count + CLLocation(latitude: prevPoint.latitude,
                                              longitude: prevPoint.longitude).distance(
                from: CLLocation(latitude: point.latitude,
                                 longitude: point.longitude))
            prevPoint = point
            return newCount
        }

        let interval = last.timestamp.timeIntervalSince1970 - first.timestamp.timeIntervalSince1970

        let milesTraveled = distanceTraveled / 1609.34
        return milesTraveled / (interval / 3600)
    }

    func computeHeading() -> Double? {
        guard count >= 2 else { return nil }
        guard let last = last else { return nil }

        let prevPoint = self[count - 2]

        let prevPoint2 = self[count - 3]

        return prevPoint.calculateBearing(to: last) * 0.8 + prevPoint2.calculateBearing(to: prevPoint) * 0.2
    }

    // Latitude -180...180 -> 0...360
    private func transform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if c.longitude < 0.0 { return CLLocationCoordinate2DMake(c.latitude, 360.0 + c.longitude) }
        return c
    }

    // Latitude 0...360 -> -180...180
    private func inverseTransform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if c.longitude > 180.0 { return CLLocationCoordinate2DMake(c.latitude, -360.0 + c.longitude) }
        return c
    }

    func region2() -> MKCoordinateRegion {
        // handle empty array
        guard count > 0 else {
            osLog("No points")
            return .boulder
        }

        // handle single coordinate
        guard count > 1 else {
            osLog("one Point")
            return MKCoordinateRegion(center: self[0].coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        }
        osLog("Calculating Region Points: \(count)")

        let transformed = map(\.coordinate).map(transform)

        // find the span
        let minLat = transformed.min { $0.latitude < $1.latitude }!.latitude
        let maxLat = transformed.max { $0.latitude < $1.latitude }!.latitude
        let minLon = transformed.min { $0.longitude < $1.longitude }!.longitude
        let maxLon = transformed.max { $0.longitude < $1.longitude }!.longitude
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(maxLat - minLat), longitudeDelta: maxLon - minLon)

        // find the center of the span
        let center = inverseTransform(c: CLLocationCoordinate2D(latitude: maxLat - span.latitudeDelta / 2, longitude: maxLon - span.longitudeDelta / 2))

        let region = MKCoordinateRegion(center: center, span: span)
        osLog(region)
        return region
    }
}

public extension Array where Element == Double {
    /// The average value of all the items in the array
    var average: Double {
        if isEmpty {
            return 0.0
        } else {
            let sum = reduce(0.0, +)
            return Double(sum) / Double(count)
        }
    }
}
