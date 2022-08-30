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

        var next: State {
            switch self {
            case .none: return .hot(0)
            case let .hot(i):
                if i < 15 {
                    return .cold(i + 1)
                } else {
                    return .rest
                }
            case let .cold(i):
                if i < 15 {
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
        // let synthesizer = AVSpeechSynthesizer()

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
                    state.value = state.next
                    timeRemaining.value = state.time

                    if let tracks = playlistWithTracks.value?.tracks, tracks.count >= 2 {
                        switch state.value {
                        case .hot:
                            let track = tracks[0]
                            if let playParameters = track.playParameters {
                                osLog(playParameters)
//                                let speech = AVSpeechUtterance(string: "Hot")
//                                synthesizer.speak(speech)
                                Task {
                                    try await Music.shared.play(playParameters: playParameters, startAt: 2.0)
                                }
                            }
                        case .cold:
                            let track = tracks[1]
                            if let playParameters = track.playParameters {
                                osLog(playParameters)
//                                let speech = AVSpeechUtterance(string: "Cold")
//                                synthesizer.speak(speech)
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
            if isRunning.value {
                Task {
                    await Music.shared.resume()
                }
            } else {
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

    func runTime(interval: Double) -> String {
        let time = Int(interval)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        var formatString = ""
        if hours == 0 {
            if minutes < 10 {
                formatString = "%2d:%0.2d"
            } else {
                formatString = "%0.2d:%0.2d"
            }
            return String(format: formatString, minutes, seconds)
        } else {
            formatString = "%2d:%0.2d:%0.2d"
            return String(format: formatString, hours, minutes, seconds)
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Segment Time left:")
                    .font(.title)
                Spacer()
                Text(runTime(interval: viewModel.timeRemaining.value))
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
                Text(runTime(interval: viewModel.runningTime.value))
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
