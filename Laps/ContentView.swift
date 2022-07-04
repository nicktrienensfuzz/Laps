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
    @ObservedObject var circleTriggerRegion = Reference<MKCircle?>(value: nil)

    init() {
        location = Location.shared.location

        points.bind(to: Location.shared.points().receive(on: RunLoop.main).eraseToAnyPublisher())
    }

    var body: some View {
//        signPost()
//        osLog("redraw: \(points.value.count)")
        NavigationView {
            VStack {
                if let location = location.value {
                    MapView(
                        region: MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                        ),

                        lineCoordinates: points.value.map(\.coordinate),
                        circleTriggerRegion: circleTriggerRegion.value
                    )
                    .frame(maxHeight: 250)
                }

//                ScrollView {
//                    VStack {
//                        ForEach()
//                    }
//                }

                Spacer()
                HStack {
                    Text("\(location.value?.coordinate.latitude ?? 0.0)")
                    Text("\(location.value?.coordinate.longitude ?? 0.0)")
                    Text("\(location.value?.course ?? 0.0)")
                }
                PlaylistView()
            }
        }.onReceive(location.didUpdate) { location in
            if circleTriggerRegion.value == nil {
                if let location = location {
                    circleTriggerRegion.value = MKCircle(center:
                        location.coordinate.move(
                            byDistance: 1000,
                            course: location.course
                        ),
                        radius: 300)
                    Location.shared.monitorRegionAtLocation(center:
                        location.coordinate.move(
                            byDistance: 1000,
                            course: location.course
                        ),
                        radius: 300,
                        identifier: "target\(Date().timeIntervalSince1970)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
