//
//  SwiftUIView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import Base
import CoreLocation
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    let region: MKCoordinateRegion
    var lineCoordinates: [CLLocationCoordinate2D]
    let circleTriggerRegion: MKCircle?

    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true

        #if targetEnvironment(simulator)
            mapView.showsTraffic = false
            mapView.showsBuildings = false
            mapView.showsCompass = false
        #endif

        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)

        if let circleTriggerRegion = circleTriggerRegion {
            mapView.addOverlay(circleTriggerRegion)
        }

        return mapView
    }

    let act = Throttler(interval: 0.2)
    func updateUIView(_ view: MKMapView, context _: Context) {
        // osLog(context)
        // osLog(lineCoordinates.count)
        if act.canPerform() {
            DispatchQueue.main.async {
                for overlay in view.overlays {
                    view.removeOverlay(overlay)
                }
                let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
                view.addOverlay(polyline)

                if let circleTriggerRegion = circleTriggerRegion {
                    view.addOverlay(circleTriggerRegion)
                }
            }
        }
    }

    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = UIColor.orange
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
            circleTriggerRegion: nil
        )
    }
}
