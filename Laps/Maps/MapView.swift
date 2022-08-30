//
//  SwiftUIView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import Base
import Combine
import CoreLocation
import FuzzCombine
import Logger
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    public init(region: MKCoordinateRegion,
                shouldUpdateToFollow: Bool = false,
                lineCoordinates: [CLLocationCoordinate2D],
                circleTriggerRegions: [MKCircle],
                tappedAt: @escaping (CLLocationCoordinate2D) -> Void,
                regionUpdated: @escaping (MKCoordinateRegion) -> Void = { _ in })
    {
        signPost()
        self.region = region
        self.shouldUpdateToFollow = shouldUpdateToFollow
        self.lineCoordinates = lineCoordinates
        self.circleTriggerRegions = circleTriggerRegions
        self.tappedAt = tappedAt
        self.regionUpdated = regionUpdated
        // self.lastRegion = lastRegion
    }

    @State fileprivate var mapView = MKMapView()

    let region: MKCoordinateRegion
    var shouldUpdateToFollow: Bool
    var lineCoordinates: [CLLocationCoordinate2D]
    let circleTriggerRegions: [MKCircle]
    let tappedAt: (CLLocationCoordinate2D) -> Void
    let regionUpdated: (MKCoordinateRegion) -> Void

    @StateObject private var lastRegion = Reference<MKCoordinateRegion?>(value: nil)
    @StateObject var act = Reference<Throttler>(value: .init(interval: 1.0))

    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.region = region
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

        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)

        circleTriggerRegions.forEach { region in
            mapView.addOverlay(region)
        }

        let gRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                 action: #selector(Coordinator.tapHandler(_:)))
        mapView.addGestureRecognizer(gRecognizer)

        return mapView
    }

    func updateUIView(_ view: MKMapView, context _: Context) {
        // osLog(context)

        if act.value.canPerform() {
            DispatchQueue.main.async {
//                if let lastRegionValue = lastRegion.value, shouldUpdateToFollow, region != lastRegionValue {
//                    mapView.region = region
//                    lastRegion.value = region
//                }

                for overlay in view.overlays {
                    view.removeOverlay(overlay)
                }
                osLog("draw line: \(lineCoordinates.count)")
                let polyline = MKPolyline(coordinates: lineCoordinates,
                                          count: lineCoordinates.count)
                view.addOverlay(polyline)

                circleTriggerRegions.forEach { region in
                    view.addOverlay(region)
                }
            }
        }
    }

    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator {
        let c = Coordinator(self)

        return c
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    var circularRegions = [CircularPOI]()
    private var publisherStorage = Set<AnyCancellable>()

    init(_ parent: MapView) {
        self.parent = parent

        super.init()
        Location.shared.circularRegions()
            .sink { [weak self] update in
                self?.circularRegions = update
            }
            .store(in: &publisherStorage)
    }

    deinit {
        signPost()
    }

    @objc func tapHandler(_ gRecognizer: UITapGestureRecognizer) {
        signPost()
        let location = gRecognizer.location(in: parent.mapView)
        // position on the map, CLLocationCoordinate2D
        let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
        osLog(coordinate)
        parent.tappedAt(coordinate)
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
        parent.regionUpdated(mapView.region)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            region: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.334803, longitude: -122.008965),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),

            lineCoordinates: [CLLocationCoordinate2D(latitude: 37.330828, longitude: -122.007495),
                              // Caffè Macs
                              CLLocationCoordinate2D(latitude: 37.336083, longitude: -122.007356),
                              // Apple wellness center
                              CLLocationCoordinate2D(latitude: 37.336901, longitude: -122.012345)],
            circleTriggerRegions: []
        ) { location in
            print(location)
        }
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center &&
            lhs.span == rhs.span
    }
}
