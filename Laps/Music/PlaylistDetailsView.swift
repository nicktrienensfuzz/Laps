//
//  PlaylistDetailsView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import Base
import Combine
import FuzzCombine
import MediaPlayer
import MusicKit
import SwiftUI
import TuvaCore

extension PlaylistDetailsView {
    class ViewModel: ObservableObject {
        @ObservedObject var playlist = BoundReference<PlaylistRecord?>(value: nil)
        @ObservedObject var playlistWithTracks = BoundReference<Playlist?>(value: nil)

        var objectWillChange: AnyPublisher<Void, Never> {
            playlist.objectWillChange
                .merge(with: playlistWithTracks.objectWillChange)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        func update(_ incomingPlaylist: PlaylistRecord) {
            playlist.value = incomingPlaylist
            Task {
                let detailedPlaylist: Playlist? = try await incomingPlaylist.playlistWithTracks()
                osLog(detailedPlaylist?.tracks)
                playlistWithTracks.value = detailedPlaylist
            }
        }

        func makeFavorite() {
            osLog(playlist.value)
            Task {
                do {
                    try await Music.shared.favorite(playlist.value.unwrapped())
                    playlist.value = playlist.value
                    osLog(playlist.value)
                } catch {
                    osLog(error)
                }
            }
        }
    }
}

struct PlaylistDetailsView: View {
    @StateObject private var viewModel = ViewModel()
    init(playlist: PlaylistRecord) {
        self.playlist = playlist
    }

    var playlist: PlaylistRecord
    @State private var songs: MPMediaItemCollection?
    @State private var showingSongPicker = false

    var body: some View {
        VStack {
            if let name = viewModel.playlist.value?.name {
                Text(name)
                    .font(.title)
            }

            Button {
                viewModel.makeFavorite()
            } label: {
                Text((viewModel.playlist.value?.selected ?? false) ? "Favorited" : "Make Favorite")
            }

            if let tracks = viewModel.playlistWithTracks.value?.tracks {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(tracks) { track in
                            Text("\(track.artistName) - \(track.title)")
                        }
                    }
                }
                .frame(minHeight: 250)
            } else {
                WaitingDots()
            }

            Button(action: {
                // self.showingSongPicker = true
                Task { @MainActor in
                    do {
                        guard let detailedPlaylist = viewModel.playlistWithTracks.value else { return }

                        if let t = detailedPlaylist.tracks?.compactMap(\.playParameters) {
                            osLog(t)
                            try await Music.shared.play(playParameters: t)
                        } else if let t = detailedPlaylist.playParameters {
                            osLog(t)
                            try await Music.shared.play(playParameters: t)
                        }
                    } catch {
                        osLog(error)
                    }
                }
            }
            ) {
                Text("Edit Test Song")
            }
            .sheet(isPresented: $showingSongPicker) {
                MusicPicker(songs: self.$songs)
            }
        }
        .onAppear(perform: { viewModel.update(playlist) })
    }
}

struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // PlaylistDetailsView()
        }
    }
}

struct MusicPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var songs: MPMediaItemCollection?

    class Coordinator: NSObject, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
        var parent: MusicPicker

        init(_ parent: MusicPicker) {
            self.parent = parent
        }

        func mediaPicker(_: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            osLog(mediaItemCollection.items.first?.title)
            parent.songs = mediaItemCollection
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MusicPicker>) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)

        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: MPMediaPickerController, context _: UIViewControllerRepresentableContext<MusicPicker>) {}
}
