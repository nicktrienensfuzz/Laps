//
//  SwiftUIView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import Base
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import Logger
import MapKit
import SwiftUI

struct MapView3: UIViewRepresentable {
    @State fileprivate var mapView = MKMapView()
    var sliderValue = BoundReference<Double>(value: 0.5)
    var followsUserLocation = Reference<Bool>(value: false)
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.region = .boulder
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsScale = true
        mapView.mapType = .hybrid

        #if targetEnvironment(simulator)
            mapView.showsTraffic = false
            mapView.showsBuildings = false
            mapView.showsCompass = false
        #endif

        return mapView
    }

    func updateUIView(_: MKMapView, context _: Context) {}

    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator3 {
        let c = Coordinator3(self)

        return c
    }
}

class Coordinator3: NSObject, MKMapViewDelegate {
    var parent: MapView3

    var circularRegions = [CircularPOI]()
    private var publisherStorage = Set<AnyCancellable>()
    var points = BoundReference<[TrackPoint]>(value: [])
    var location: Reference<CLLocation?>
    var region = Reference<MKCoordinateRegion>(value: .boulder)
    var followsUserLocation = Reference<Bool>(value: false)
    var lastRegion = Reference<MKCoordinateRegion?>(value: nil)

    init(_ parent: MapView3) {
        self.parent = parent
        location = Location.shared.location
        followsUserLocation = parent.followsUserLocation
        super.init()

        let gRecognizer = UITapGestureRecognizer(target: self,
                                                 action: #selector(Coordinator.tapHandler(_:)))
        parent.mapView.addGestureRecognizer(gRecognizer)

        Location.shared.circularRegions()
            .sink { [weak self] update in
                self?.circularRegions = update
            }
            .store(in: &publisherStorage)

        points.bind(to:
            Location.shared.points()
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher())

        location.currentValueWithUpdates
            .filterNil()
            .combineLatest(region.currentValueWithUpdates,
                           followsUserLocation.currentValueWithUpdates)
            .map { location, lastRegion, following -> MKCoordinateRegion in
                if lastRegion == .boulder {
                    return MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.0016923261917511923,
                            longitudeDelta: 0.0022739952207047054
                        )
                    )
                }
                guard following else {
                    return lastRegion
                }
                let newRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: lastRegion.span
                )
                osLog("updating region based on user location")
                return newRegion
            }
            .assign(to: \.value, on: region)
            .store(in: &publisherStorage)

        location.currentValueWithUpdates
            .combineLatest(region.currentValueWithUpdates, points.currentValueWithUpdates)
            .sink { _, _, _ in
                self.updateMap()
            }
            .store(in: &publisherStorage)
    }

    func updateMap() {
        if let lastRegionValue = lastRegion.value, followsUserLocation.value, region.value != lastRegionValue {
            parent.mapView.region = region.value
            lastRegion.value = region.value
        }

        for overlay in parent.mapView.overlays {
            parent.mapView.removeOverlay(overlay)
        }
        osLog("draw line: \(points.count)")
        let polyline = MKPolyline(coordinates: points.value.map(\.coordinate),
                                  count: points.value.count)
        parent.mapView.addOverlay(polyline)

        circularRegions.forEach { region in
            parent.mapView.addOverlay(region.circle)
        }
    }

    deinit {
        signPost()
    }

    @objc func tapHandler(_ gRecognizer: UITapGestureRecognizer) {
        let location = gRecognizer.location(in: parent.mapView)
        let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
        let radius = 30 * parent.sliderValue.value

        Task {
            do {
                try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                    let point = CircularPOI(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        radius: radius,
                        trackId: nil,
                        timestamp: Date()
                    )
                    try point.save(db)

                    Location.shared.monitorRegionAtLocation(center:
                        coordinate,
                        radius: radius,
                        identifier: point.id)
                }
            } catch {
                osLog(error)
            }
        }
    }

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            let inRegion = circularRegions.contains {
                circle.coordinate == $0.coordinate &&
                    $0.enteredAt != nil
            }
            renderer.strokeColor = inRegion ? UIColor.green : UIColor.orange
            renderer.lineWidth = 10
            return renderer
        }
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 10
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If the annotation is the user blue dot, return nil
        if annotation is MKUserLocation {
            return nil
        }
        // Check if there's a reusable annotation view first
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Constants.annotationReuseId")
        if annotationView == nil {
            // Create a new one
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Constants.annotationReuseId")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            // We got a reusable one
            annotationView!.annotation = annotation
        }
        // Return it
        return annotationView
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        osLog(mapView.region)
        // parent.regionUpdated(mapView.region)
    }
}

struct MapView3_Previews: PreviewProvider {
    static var previews: some View {
        MapView3()
    }
}
