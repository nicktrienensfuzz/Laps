//
//  SwiftUIView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import SwiftUI
import MapKit
import CoreLocation
import Base

struct MapView: UIViewRepresentable {
    
    let region: MKCoordinateRegion
    var lineCoordinates: [CLLocationCoordinate2D]
    
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        
        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
       // osLog(context)
        //osLog(lineCoordinates.count)
        DispatchQueue.main.async {
            for overlay in view.overlays {
                view.removeOverlay(overlay)
            }
            let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
            view.addOverlay(polyline)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
            
            lineCoordinates:  [CLLocationCoordinate2D(latitude: 37.330828, longitude: -122.007495),
                              // Caffè Macs
                              CLLocationCoordinate2D(latitude: 37.336083, longitude: -122.007356),
                              // Apple wellness center
                              CLLocationCoordinate2D(latitude: 37.336901, longitude:  -122.012345)]
        )
    }
}
