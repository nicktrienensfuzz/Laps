//
//  TrackListView.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/6/22.
//

import Base
import Combine
import SwiftUI
import TuvaCore

struct TrackListView: View {
    @State var tracks = [Track]()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(tracks, id: \.id) { track in
                    NavigationLink(destination: {
                        TrackDetailView(track: track)
                    }, label: {
                        HStack {
                            Text(track.id.prefix(8))
                            Spacer()
                            Text(track.startTime.toFormat("MM/dd"))
                        }
                    })
                }
            }
            .onReceive(Location.shared.tracks(), perform: { newTracks in
                // osLog(newTracks.count)
                tracks = newTracks
            })
        }
    }
}

struct TrackList_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView()
    }
}
