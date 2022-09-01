//
//  WorkOutForHolly.swift
//  Laps
//
//  Created by Nicholas Trienens on 8/14/22.
//

import AVFoundation
import Base
import BaseWatch
import Combine
import CoreLocation
import DependencyContainer
import FuzzCombine
import Logger
import MapKit
import MusadoraKit
import MusicKit
import SwiftUI
import TuvaCore

extension WorkOutForHollyView {
    enum State: Equatable {
        case none
        case hot(Int)
        case cold(Int)
        case rest

        var time: Double {
            switch self {
            case .none: return 30
            case .hot, .cold: return 30
            case .rest: return 600
            }
        }

        var asString: String {
            switch self {
            case .none: return "Not Started"
            case let .hot(i): return "Hot \(i + 1) / 16"
            case let .cold(i): return "Cold \(i + 1) / 16"
            case .rest: return "Rest"
            }
        }

        var isHot: Bool {
            switch self {
            case .hot: return true
            default: return false
            }
        }

        func next(limit: Int = 16) -> State {
            switch self {
            case .none: return .hot(0)
            case let .hot(i):
                if i < limit - 1 {
                    return .cold(i + 1)
                } else {
                    return .rest
                }
            case let .cold(i):
                if i < limit - 1 {
                    return .hot(i + 1)
                } else {
                    return .rest
                }
            case .rest: return .hot(0)
            }
        }
    }

    class ViewModel: ObservableObject {
        private var publisherStorage = Set<AnyCancellable>()

        @ObservedObject var sliderValue = BoundReference<Double>(value: 0.5)
        @ObservedObject var isRunning = Reference<Bool>(value: false)
        @ObservedObject var state = Reference<State>(value: .none)

        @ObservedObject var timeRemaining = Reference<Double>(value: 0.1)
        @ObservedObject var runningTime = Reference<Double>(value: 0.0)

        @ObservedObject var playlistWithTracks = BoundReference<Playlist?>(value: nil)

        var startedAt: Date = .distantPast

        var progress: Double {
            if timeRemaining.value > 0 {
                return timeRemaining.value / state.time
            } else {
                return 1
            }
        }

        var objectWillChange: AnyPublisher<Void, Never> {
            state.objectWillChange
                .merge(with: timeRemaining.objectWillChange)
                .merge(with: isRunning.objectWillChange)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        init() {
            Task {
                playlistWithTracks.value = try await Music.shared.selectedPlaylist()
                osLog(playlistWithTracks.value?.tracks)
            }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                self.update()
            })
        }

        func update() {
            if isRunning.value {
                timeRemaining.value -= 0.1
                runningTime.value += 0.1

                if timeRemaining.value <= 0 {
                    osLog("Phase Ended")
                    state.value = state.value.next()
                    timeRemaining.value = state.time

                    if let tracks = playlistWithTracks.value?.tracks, tracks.count >= 2 {
                        switch state.value {
                        case .hot:
                            let track = tracks[0]
                            if let playParameters = track.playParameters {
                                osLog(playParameters)

                                Task {
                                    try await Music.shared.play(playParameters: playParameters, startAt: 2.0)
                                }
                            }
                        case .cold:
                            let track = tracks[1]
                            if let playParameters = track.playParameters {
                                osLog(playParameters)

                                Task {
                                    try await Music.shared.play(playParameters: playParameters, startAt: 8)
                                }
                            }
                        default: return
                        }
                    }
                }
            }
        }

        func toggleRecording() {
            isRunning.value.toggle()
            Location.shared.isTracking.value = isRunning.value
            
            if isRunning.value {
                Location.shared.startMonitoringSignificantLocationChanges()
                Task {
                    await Music.shared.resume()
                }
            } else {
                Location.shared.stopMonitoringSignificantLocationChanges()
                Task {
                    await Music.shared.pause()
                }
            }
        }
    }
}

struct WorkOutForHollyView: View {
    @StateObject private var viewModel = ViewModel()

    @ObservedObject var location: Reference<CLLocation?>
    init() {
        location = Location.shared.location
    }

    var body: some View {
        VStack {
            HStack {
                Text("Segment Time left:")
                    .font(.title)
                Spacer()
                Text(viewModel.timeRemaining.value.runTime)
                    .font(.title)
            }

            ProgressBar(value: viewModel.progress, foregroundColor: viewModel.state.isHot ? Color.red : Color.blue)
                .frame(height: 80)

            InfoBarView()
            HeartRateView()
                .padding(.horizontal)

            Spacer()
            Text(viewModel.state.asString)
                .font(.title)
            HStack {
                Text("Total Time:")
                    .font(.title)
                Spacer()
                Text(viewModel.runningTime.value.runTime)
                    .font(.title)
            }

            Button {
                viewModel.toggleRecording()
            } label: {
                if !viewModel.isRunning.value {
                    Text("Start workout")
                        .font(.title)
                } else {
                    Text("Pause workout")
                        .font(.title)
                }
            }
            .buttonStyle(.borderedProminent)

            BackButton()
        }
        .padding(.top, 35)
        .padding(.bottom, 45)
        .padding(.horizontal, 12)
        .ignoresSafeArea()
    }
}

struct WorkOutForHollyView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOutForHollyView()
    }
}

struct ProgressBar: View {
    internal init(value: Double,
                  foregroundColor: Color = Color(UIColor.systemBlue))
    {
        self.value = value
        self.foregroundColor = foregroundColor
    }

    let value: Double
    let foregroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))

                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(foregroundColor)
            }
            .cornerRadius(min(20, geometry.size.height / 2))
        }
    }
}
