//
//  RecordTrack.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/26/22.
//

import SwiftUI

import Base
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import MapKit
import SwiftUI

extension RecordTrackView {
    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        @ObservedObject var sliderValue = BoundReference<Double>(value: 0.5)
        @ObservedObject var circleTriggerRegions = Reference<[MKCircle]>(value: [])
        @ObservedObject var regions = BoundReference<[CircularPOI]>(value: [])

        @ObservedObject var isRecording = Reference<Bool>(value: false)
        @ObservedObject var name = Reference<String>(value: "")

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

        func toggleRecording() {
            isRecording.value.toggle()
            if isRecording.value {
                Location.shared.startMonitoringSignificantLocationChanges()
            } else {
                Location.shared.stopMonitoringSignificantLocationChanges()
            }
        }

        func clearRegions() {
            Task {
                do {
                    try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                        try CircularPOI.deleteAll(db)

                        Location.shared.stopMonitoringAllRegions()
                    }
                } catch {
                    osLog(error)
                }
            }
        }

        func addRegion(_ location: CLLocationCoordinate2D) {
            let radius = 30.0 * sliderValue.value

            Task {
                do {
                    try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

                        let point = CircularPOI(
                            latitude: location.latitude,
                            longitude: location.longitude,
                            radius: radius,
                            trackId: nil,
                            timestamp: Date()
                        )
                        try point.save(db)

                        Location.shared.monitorRegionAtLocation(center:
                            location,
                            radius: radius,
                            identifier: point.id)
                    }
                } catch {
                    osLog(error)
                }
            }
        }
    }
}

struct RecordTrackView: View {
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
        VStack {
            if let location = location.value {
                VStack(spacing: 0) {
                    HStack {
                        Button("Clear All") {
                            viewModel.clearRegions()
                        }.padding(.leading)
                        Spacer()
                    }
                    .padding(4)
                    MapView(
                        region: MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.0032, longitudeDelta: 0.0032)
                        ),

                        lineCoordinates: points.value.map(\.coordinate),
                        circleTriggerRegions: viewModel.circleTriggerRegions.value,
                        tappedAt: { location in
                            viewModel.addRegion(location)
                        }
                    )
                    .frame(height: 250)

                    CustomDraggableComponent {
                        viewModel.sliderValue.value = $0
                    }
                }
                .neumorphicStyle()
            } else {
                WaitingDots()
            }
        }

        TextField("Name", text: viewModel.name.asBinding())
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.gray.opacity(0.24))
            }
            .padding()

        Button {
            viewModel.toggleRecording()
        } label: {
            if !viewModel.isRecording.value {
                Text("Start Recording")
            } else {
                Text("Pause Recording")
            }
        }
    }
}

struct RecordTrackView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTrackView()
    }
}
