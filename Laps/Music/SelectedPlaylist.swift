//
//  SelectedPlaylist.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/24/22.
//

import Base
import Combine
import FuzzCombine
import Logger
import SwiftUI

extension SelectedPlaylist {
    class ViewModel: ObservableObject {
        @ObservedObject var selectedPlaylist = BoundReference<PlaylistRecord?>(value: nil)
        @ObservedObject var playlists = BoundReference<[PlaylistRecord]>(value: [])

        var objectWillChange: AnyPublisher<Void, Never> {
            selectedPlaylist.objectWillChange
                .merge(with: playlists.objectWillChange)
                .throttle(for: 0.2, scheduler: RunLoop.main, latest: true)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        init() {
            Task {
                for await update in await Music.shared.observablePlaylists().values {
                    osLog(update)
                    playlists.value = update

                    if let p = update.first(where: { $0.selected ?? false }) {
                        selectedPlaylist.value = p
                    }
                }
            }
        }
    }
}

struct SelectedPlaylist: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Selected Playlist")
                    .padding([.top, .leading], 5)

                VStack(alignment: .leading) {
                    ForEach(viewModel.playlists.value) { playlist in
                        NavigationLink {
                            PlaylistDetailsView(playlist: playlist)
                        } label: {
                            if playlist.selected ?? false {
                                Text(playlist.name)
                                    .bold()
                            } else {
                                Text(playlist.name)
                            }
                        }
                        .padding(.top, 1)
                    }
                }
                .padding([.leading, .bottom])
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SelectedPlaylist_Previews: PreviewProvider {
    static var previews: some View {
        SelectedPlaylist()
    }
}
