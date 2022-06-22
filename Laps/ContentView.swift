//
//  ContentView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import SwiftUI
import Base
import CoreLocation
import MapKit

struct ContentView: View {
    @State var location: CLLocation?
    var body: some View {
        NavigationView {
        VStack {
            MapView(
                region: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.334803, longitude: -122.008965),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
                
                lineCoordinates:  [CLLocationCoordinate2D(latitude: 37.330828, longitude: -122.007495),
                                  CLLocationCoordinate2D(latitude: 37.336083, longitude: -122.007356),
                                  CLLocationCoordinate2D(latitude: 37.336901, longitude:  -122.012345)]
            )
            .frame(maxHeight: 250)

            HStack {
                Text("\(location?.coordinate.latitude ?? 0.0)")
                Text("\(location?.coordinate.longitude ?? 0.0)")
            }
            PlaylistView()
            
        }
        }.task {
            do {
                try await Location.shared.request()
                for await locationUpdateEvent in await Location.shared.startUpdatingLocation() {
                    switch locationUpdateEvent {
                    case .didUpdateLocations(let locations):
                        self.location = locations.first
                        //print(locations.first)
                    case .didFailWith(let error):
                        // do something
                        print(error)
                    case .didPaused, .didResume:
                        break
                    }
                }

            } catch {
                print(error)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
