//
//  InfoBarView.swift
//  Laps
//
//  Created by Nicholas Trienens on 8/21/22.
//

import Base
import Combine
import FuzzCombine
import Logger
import SwiftUI

struct InfoBarView: View {
    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        @ObservedObject var points = Reference<[TrackPoint]>(value: [])

        var objectWillChange: AnyPublisher<Void, Never> {
            points.objectWillChange
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        init() {
//            Timer.publish(every: 3.0, on: RunLoop.main, in: .common)
//                .autoconnect()
//                .flatMap { _ in
            Location.shared.points()
                // }
                .sink { points in
                    // osLog(points.last)
                    self.points.value = points
                }
                .store(in: &publisherStorage)
        }
    }

    @StateObject private var viewModel = ViewModel()

    init() {}

    var body: some View {
        HStack {
            box(label: "Speed", value: String(format: "%0.2f", viewModel.points.last?.speed ?? 0))
            Spacer()
            Divider()
            Spacer()
            box(label: "Speed 3m", value:
                String(format: "%0.2f", viewModel.points.value.averageSpeedSince(startDate: Date().addingTimeInterval(-180))))
            Spacer()
            Divider()
            Spacer()
            box(label: "Speed 10m", value: String(format: "%0.2f", viewModel.points.value.averageSpeedSince(startDate: Date().addingTimeInterval(-600))))
        }
        .frame(maxHeight: 70)
    }

    func box(label: String, value: String) -> some View {
        VStack {
            Text(label)
                .bold()
            Text(value)
                .font(.title)
        }
    }
}

struct InfoBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InfoBarView()
                .fixedSize()
        }
    }
}
