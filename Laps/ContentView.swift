//
//  ContentView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import BaseWatch
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import MapKit
import SwiftUI

extension ContentView {
    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        @ObservedObject var sliderValue = BoundReference<Double>(value: 0.5)
        @ObservedObject var circleTriggerRegions = Reference<[MKCircle]>(value: [])
        @ObservedObject var regions = BoundReference<[CircularPOI]>(value: [])

        var objectWillChange: AnyPublisher<Void, Never> {
            circleTriggerRegions.objectWillChange
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        init() {
            Location.shared.allRegions()
            regions.didUpdate
                .sink { r in
                    self.circleTriggerRegions.value = r.map {
                        MKCircle(center: $0.coordinate, radius: $0.radius)
                    }
                }
                .store(in: &publisherStorage)

            regions.bind(to: Location.shared.regions())
        }

//        func addRegion(_ location: CLLocationCoordinate2D) {
//            let radius = 30.0 * sliderValue.value
//
//            Task {
//                do {
//                    try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in
//
//                        let point = CircularPOI(
//                            latitude: location.latitude,
//                            longitude: location.longitude,
//                            radius: radius,
//                            trackId: nil,
//                            timestamp: Date()
//                        )
//                        try point.save(db)
//
//                        Location.shared.monitorRegionAtLocation(center:
//                            location,
//                            radius: radius,
//                            identifier: point.id)
//                    }
//                } catch {
//                    osLog(error)
//                }
//            }
//        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    @ObservedObject var location: Reference<CLLocation?>
    @ObservedObject var points = BoundReference<[TrackPoint]>(value: [])

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
//                    if let location = location.value {
//                        VStack(spacing: 0) {
//                            MapView(
//                                region: MKCoordinateRegion(
//                                    center: location.coordinate,
//                                    span: MKCoordinateSpan(latitudeDelta: 0.0032, longitudeDelta: 0.0032)
//                                ),
//
//                                lineCoordinates: points.value.map(\.coordinate),
//                                circleTriggerRegions: viewModel.circleTriggerRegions.value,
//                                tappedAt: { location in
//                                    viewModel.addRegion(location)
//                                }
//                            )
//                            .frame(height: 250)
//
//                            CustomDraggableComponent {
//                                viewModel.sliderValue.value = $0
//                            }
//                        }
//                        .neumorphicStyle()
//                    } else {
//                        WaitingDots()
//                    }

                    NavigationLink {
                        WorkOutForHollyView()
                    } label: {
                        Text("Holly's 30s")
                            .font(.title2)
                    }
                    NavigationLink {
                        RecordTrackView()
                    } label: {
                        Text("Record New Track")
                            .bold()
                    }
                    .padding(.top, 30)

                    Spacer()

                    TrackListView()
                        .padding()
                        .neumorphicStyle()

                    SelectedPlaylist()
                        .frame(maxWidth: .infinity)
                        .neumorphicStyle()

                    Spacer()
                }
            }
            .background(Color(.displayP3, red: 0.93, green: 0.94, blue: 0.94, opacity: 1))
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
