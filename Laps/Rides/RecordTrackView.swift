//
//  RecordTrack.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/26/22.
//

import Base
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import Logger
import MapKit
import NavigationStack
import SwiftUI

extension RecordTrackView {
    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        @ObservedObject var sliderValue = BoundReference<Double>(value: 0.5)
        @ObservedObject var circleTriggerRegions = Reference<[MKCircle]>(value: [])
        @ObservedObject var regions = BoundReference<[CircularPOI]>(value: [])
        @ObservedObject var points = BoundReference<[TrackPoint]>(value: [])
        @ObservedObject var location: Reference<CLLocation?>

        @ObservedObject var isRecording = Location.shared.isTracking
        @ObservedObject var name = Reference<String>(value: "")
        var region = Reference<MKCoordinateRegion>(value: .boulder)
        var followsUserLocation = Reference<Bool>(value: false)

        var objectWillChange: AnyPublisher<Void, Never> {
            points.objectWillChange
                .merge(with: isRecording.objectWillChange)
                .throttle(for: 0.4, scheduler: RunLoop.main, latest: true)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        init() {
            Location.shared.allRegions()
            location = Location.shared.location

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

            points.bind(to:
                Location.shared.points()
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher())

            regions.didUpdate
                .sink { r in
                    osLog(r.count)
                    self.circleTriggerRegions.value = r.map(\.circle)
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

        func userUpdatedRegion(_ region: MKCoordinateRegion) {
            if followsUserLocation.value {
                self.region.value.span = region.span
            } else {
                self.region.value = region
            }
        }
    }
}

struct RecordTrackView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Screen {
            VStack {
                BackButton()
                if viewModel.location.value != nil {
                    InfoBarView()
                    HeartRateView()
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        HStack {
                            Button("Clear All Triggers ") {
                                viewModel.clearRegions()
                            }.padding(.leading)
                            Spacer()
                            Text("Points: \(viewModel.points.value.count)")

                            Spacer()
                            Toggle(isOn: viewModel.followsUserLocation.asBinding()) {
                                Text("follow")
                            }
                            .fixedSize()
                        }
                        .padding(4)

                        MapView3(sliderValue: viewModel.sliderValue)
                            .frame(minHeight: 250, maxHeight: 350)

                        CustomDraggableComponent {
                            viewModel.sliderValue.value = $0
                        }
                    }
                    .neumorphicStyle()
                } else {
                    WaitingDots()
                }

                Spacer()
//            TextField("Name", text: viewModel.name.asBinding())
//                .padding(6)
//                .background {
//                    RoundedRectangle(cornerRadius: 6)
//                        .foregroundColor(Color.gray.opacity(0.24))
//                }
//                .padding()

                Button {
                    viewModel.toggleRecording()
                } label: {
                    if !viewModel.isRecording.value {
                        Text("Start Recording").font(.title)
                    } else {
                        Text("Pause Recording").font(.title)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct RecordTrackView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTrackView()
    }
}
