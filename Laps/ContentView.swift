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
import DependencyContainer
import FuzzCombine
import Combine

struct ContentView: View {
    @State var location: CLLocation?
    @State var points = [TrackPoint]()
    
    var body: some View {
        NavigationView {
            VStack {
                
                if let location = location {
                    
                
                MapView(
                    region: MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ),
                    
                    lineCoordinates: points.map(\.coordinate)
                )
                .frame(maxHeight: 250)
                }
                
                Spacer()
                HStack {
                    Text("\(location?.coordinate.latitude ?? 0.0)")
                    Text("\(location?.coordinate.longitude ?? 0.0)")
                }
                PlaylistView()
                
            }
        }
        .onReceive(try! DependencyContainer.resolve(key: ContainerKeys.database).observeAll(TrackPoint.all()).catch{ error -> AnyPublisher<[TrackPoint], Never> in
            osLog(error)
            return Just.any([TrackPoint]())
        }.receive(on: RunLoop.main), perform: { points in
            
            self.points = points
            
        })
        .task {
            do {
                let track = try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write({ db -> Track in
                    let track = Track(startTime: Date())
                    try track.save(db)
                    // try TrackPoint.deleteAll(db)
                    return track
                })
                
                try await Location.shared.request()
                for await locationUpdateEvent in await Location.shared.startUpdatingLocation() {
                    switch locationUpdateEvent {
                    case .didUpdateLocations(let locations):
                        self.location = locations.first
                        //print(locations.first)
                        if let location = locations.first {
                            try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write({ db in
                                
                                let point = TrackPoint(latitude: location.coordinate.latitude,
                                                       longitude: location.coordinate.longitude,
                                                       timestamp: location.timestamp,
                                                       trackId: track.id)
                                try point.save(db)
                            })
                        }
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
