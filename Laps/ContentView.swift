//
//  ContentView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import MapKit
import SwiftUI

open class BoundReference<Value>: Reference<Value> {
    private var publisherStorage = Set<AnyCancellable>()
    open func bind(to: AnyPublisher<Value, Never>) {
        to.assign(to: \.value, on: self)
            .store(in: &publisherStorage)
    }

    open func drive(on subject: PassthroughSubject<Value, Never>) {
        didUpdate.bind(to: subject)
            .store(in: &publisherStorage)
    }
}

struct ContentView: View {
    @ObservedObject var location: Reference<CLLocation?>
    @ObservedObject var points = BoundReference<[TrackPoint]>(value: [])
    @ObservedObject var circleTriggerRegions = Reference<[MKCircle]>(value: [])

    init() {
        location = Location.shared.location

        points.bind(to:
            Location.shared.points()
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher())
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let location = location.value {
                        MapView(
                            region: MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                            ),

                            lineCoordinates: points.value.map(\.coordinate),
                            circleTriggerRegions: circleTriggerRegions.value,
                            tappedAt: { location in
                                let radius = 15.0

                                self.circleTriggerRegions.value.append(MKCircle(
                                    center:
                                    location,
                                    radius: radius
                                ))
                                Location.shared.monitorRegionAtLocation(center:
                                    location,
                                    radius: radius,
                                    identifier: "target\(Date().timeIntervalSince1970)")

                                Task {
                                    do {
                                        try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                                            let point = CircularPOI(
                                                latitude: location.latitude,
                                                longitude: location.longitude,
                                                radius: 15,
                                                trackId: nil,
                                                timestamp: Date()
                                            )
                                            try point.save(db)
                                        }
                                    } catch {
                                        osLog(error)
                                    }
                                }
                            }
                        )
                        .frame(height: 250)
                        .neumorphicStyle()
                    } else {
                        WaitingDots()
                    }

                    TrackListView()
                        .padding()
                        .neumorphicStyle()

                    SelectedPlaylist()
                        .frame(maxWidth: .infinity)
                        .neumorphicStyle()

                    Spacer()
                    IntervalBuilderView()
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
//        .onReceive(location.didUpdate) { location in
//            let radius = 15.0
//            if circleTriggerRegions.value.isEmpty {
//                if let location = location {
//                    circleTriggerRegions.value = []
//                    let intersection2 = CLLocationCoordinate2D(latitude: 48.84342958760746, longitude: -122.40568967486759)
//                    circleTriggerRegions.value.append(MKCircle(center:
//                        intersection2,
//                        radius: radius))
//                    Location.shared.monitorRegionAtLocation(center:
//                        intersection2,
//                        radius: radius,
//                        identifier: "target\(Date().timeIntervalSince1970)")
//
//                    let intersection = location.coordinate.move(
//                        byDistance: 1000,
//                        course: location.course
//                    )
//                    // let intersection = CLLocationCoordinate2D(latitude: 48.84370499670961, longitude: -122.40773336425492)
//                    circleTriggerRegions.value.append(MKCircle(center:
//                        intersection,
//                        radius: radius))
//                    Location.shared.monitorRegionAtLocation(center:
//                        intersection,
//                        radius: radius,
//                        identifier: "target\(Date().timeIntervalSince1970)")
//                }
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
