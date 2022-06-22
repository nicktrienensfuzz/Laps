//
//  PlaylistDetailsView.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/21/22.
//

import SwiftUI
import MusicKit

struct PlaylistDetailsView: View {
    var playlist: Playlist

    var body: some View {
        VStack{
            ForEach(playlist.tracks!) { track in
                Text("\(track.artistName)")
                
            }
        }
    }
}

struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
        //PlaylistDetailsView()
    }
    }
}
