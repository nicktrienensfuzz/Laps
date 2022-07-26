//
//  PlaylistView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import Base
import FuzzCombine
import MusicKit
import SwiftUI

struct PlaylistView: View {
    @ObservedObject var playlists: BoundReference<[PlaylistRecord]>

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(playlists.value) { playlist in

                    NavigationLink {
                        PlaylistDetailsView(playlist: playlist)
                    } label: {
                        Text(playlist.name)
                            .bold()
                    }
                }
            }
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(playlists: BoundReference<[PlaylistRecord]>(value: []))
    }
}
