//
//  MKCoordinateRegion.swift
//
//
//  Created by Nicholas Trienens on 7/23/22.
//

import CoreLocation
import Foundation
import MapKit

public extension MKCoordinateRegion {
    static var washington: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.84342958760746, longitude: -122.40568967486759),
            span: MKCoordinateSpan(
                latitudeDelta: 0.03,
                longitudeDelta: 0.03
            )
        )
    }

    @available(*, unavailable, renamed: "init(center:latitudinalMeters:longitudinalMeters:)")
    init(center: CLLocationCoordinate2D, latitudalDistance: CLLocationDistance, longitudalDistance: CLLocationDistance) {
        self.init(center: center, latitudinalMeters: latitudalDistance, longitudinalMeters: longitudalDistance)
    }

    init(north: CLLocationDegrees, east: CLLocationDegrees, south: CLLocationDegrees, west: CLLocationDegrees) {
        let span = MKCoordinateSpan(latitudeDelta: north - south, longitudeDelta: east - west)
        let center = CLLocationCoordinate2D(latitude: north - (span.latitudeDelta / 2), longitude: west + (span.longitudeDelta / 2))

        self.init(
            center: center,
            span: span
        )
    }

    init? <Coordinates: Sequence>(fittingCoordinates coordinates: Coordinates) where Coordinates.Iterator.Element == CLLocationCoordinate2D {
        var minLatitude = CLLocationDegrees(90)
        var maxLatitude = CLLocationDegrees(-90)
        var minLongitude = CLLocationDegrees(180)
        var maxLongitude = CLLocationDegrees(-180)

        var hasCoordinates = false
        for coordinate in coordinates {
            hasCoordinates = true

            if coordinate.latitude < minLatitude {
                minLatitude = coordinate.latitude
            }
            if coordinate.latitude > maxLatitude {
                maxLatitude = coordinate.latitude
            }
            if coordinate.longitude < minLongitude {
                minLongitude = coordinate.longitude
            }
            if coordinate.longitude > maxLongitude {
                maxLongitude = coordinate.longitude
            }
        }

        if !hasCoordinates {
            return nil
        }

        self.init(north: maxLatitude, east: maxLongitude, south: minLatitude, west: minLongitude)
    }

//
//    func contains(_ point: CLLocationCoordinate2D) -> Bool {
//        guard (point.latitude - center.latitude).absolute >= span.latitudeDelta else {
//            return false
//        }
//        guard (point.longitude - center.longitude).absolute >= span.longitudeDelta else {
//            return false
//        }
//
//        return true
//    }
//
//
//
//    func contains(_ region: MKCoordinateRegion) -> Bool {
//        guard span.latitudeDelta - region.span.latitudeDelta - (center.latitude - region.center.latitude).absolute >= 0 else {
//            return false
//        }
//        guard span.longitudeDelta - region.span.longitudeDelta - (center.longitude - region.center.longitude).absolute >= 0 else {
//            return false
//        }
//
//        return true
//    }
//

    var east: CLLocationDegrees {
        center.longitude + (span.longitudeDelta / 2)
    }

    mutating func insetBy(latitudinally latitudeDelta: Double, longitudinally longitudeDelta: Double = 0) {
        self = insettedBy(latitudinally: latitudeDelta, longitudinally: longitudeDelta)
    }

    mutating func insetBy(latitudinally longitudeDelta: Double) {
        insetBy(latitudinally: 0, longitudinally: longitudeDelta)
    }

    func insettedBy(latitudinally latitudeDelta: Double, longitudinally longitudeDelta: Double = 0) -> MKCoordinateRegion {
        var region = self
        region.span.latitudeDelta += latitudeDelta
        region.span.longitudeDelta += longitudeDelta
        return region
    }

    func insettedBy(longitudinally longitudeDelta: Double) -> MKCoordinateRegion {
        insettedBy(latitudinally: 0, longitudinally: longitudeDelta)
    }

    func intersectedWith(_ region: MKCoordinateRegion) -> MKCoordinateRegion? {
        guard intersects(region) else {
            return nil
        }

        return MKCoordinateRegion(
            north: min(north, region.north),
            east: min(east, region.east),
            south: max(south, region.south),
            west: max(west, region.west)
        )
    }

    func intersects(_ region: MKCoordinateRegion) -> Bool {
        if region.north < south {
            return false
        }
        if north < region.south {
            return false
        }
        if east < region.west {
            return false
        }
        if region.east < west {
            return false
        }

        return true
    }

    var north: CLLocationDegrees {
        center.latitude + (span.latitudeDelta / 2)
    }

    var northEast: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: north, longitude: east)
    }

    var northWest: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: north, longitude: west)
    }

    mutating func scaleBy(_ scale: Double) {
        scaleBy(latitudinally: scale, longitudinally: scale)
    }

    mutating func scaleBy(latitudinally latitudalScale: Double, longitudinally longitudalScale: Double = 1) {
        self = scaledBy(latitudinally: latitudalScale, longitudinally: longitudalScale)
    }

    mutating func scaleBy(longitudinally longitudalScale: Double) {
        scaleBy(latitudinally: 1, longitudinally: longitudalScale)
    }

    func scaledBy(_ scale: Double) -> MKCoordinateRegion {
        scaledBy(latitudinally: scale, longitudinally: scale)
    }

    func scaledBy(latitudinally latitudalScale: Double, longitudinally longitudalScale: Double = 1) -> MKCoordinateRegion {
        insettedBy(latitudinally: (span.latitudeDelta / 2) * latitudalScale, longitudinally: (span.longitudeDelta / 2) * longitudalScale)
    }

    func scaledBy(longitudinally: Double) -> MKCoordinateRegion {
        scaledBy(latitudinally: 1, longitudinally: longitudinally)
    }

    var south: CLLocationDegrees {
        center.latitude - (span.latitudeDelta / 2)
    }

    var southEast: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: south, longitude: east)
    }

    var southWest: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: south, longitude: west)
    }

    var west: CLLocationDegrees {
        center.longitude - (span.longitudeDelta / 2)
    }

    static let world: MKCoordinateRegion = .init(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360))
}

extension MKCoordinateSpan: Equatable {
    public static func == (a: MKCoordinateSpan, b: MKCoordinateSpan) -> Bool {
        a.latitudeDelta == b.latitudeDelta && a.longitudeDelta == b.longitudeDelta
    }
}
