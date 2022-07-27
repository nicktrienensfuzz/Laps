//
//  File.swift
//
//
//  Created by Nicholas Trienens on 7/1/22.
//

import CoreLocation
import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

public extension CLLocationCoordinate2D {
    /// Get coordinate moved from current to `distanceMeters` meters with azimuth `azimuth` [0, Double.pi)
    ///
    /// - Parameters:
    ///   - distanceMeters: the distance in meters
    ///   - course: the azimuth (bearing) in degrees
    /// - Returns: new coordinate
    func move(byDistance distanceMeters: Double, course bearing: Double) -> CLLocationCoordinate2D {
        let bearing = bearing.degreesToRadians

        let origin = self
        let distRadians = distanceMeters / 6_372_797.6 // earth radius in meters

        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }

    // Distance in meters, as explained in CLLocationDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
