//
//  PlaylistView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import SwiftUI
import MusicKit
import Base


struct PlaylistView: View {
    @State var playlists: MusicItemCollection<Playlist>? = nil
    
    var body: some View {
        VStack {
            if let playlists = playlists {
                VStack {
                    
                    ForEach(playlists) { playlist in
                        
                        NavigationLink {
                            PlaylistDetailsView(playlist: playlist)
                        } label: {
                            Text(playlist.name)
                                .bold()
                        }
                    }
                }
            }else {
                Text("loading")
            }
        }
        .task {
            do {
                let songs = try await Music.shared.playlists()
                playlists = songs
                print(songs)
            } catch {
                print(error)
            }
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
