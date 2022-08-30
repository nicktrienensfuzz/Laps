//
//  TrackListView.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/6/22.
//

import Base
import Combine
import Logger
import NavigationStack
import SwiftUI
import TuvaCore

struct TrackListView: View {
    @State var tracks = [Track]()
    @EnvironmentObject private var navigationStack: NavigationStackCompat

    var body: some View {
        ScrollView {
            VStack {
                ForEach(tracks, id: \.id) { track in
                    Button {
                        navigationStack.push(TrackDetailView(track: track))
                    }
                label: {
                        HStack {
                            Text(track.id.prefix(4))
                            Spacer()
                            TrackPoints(track: track)
                            Text(track.startTime.toFormat("MM/dd"))
                        }
                    }
                }
            }
            .onReceive(Location.shared.tracks(), perform: { newTracks in
                osLog(newTracks.count)
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

struct TrackPoints: View {
    let track: Track
    @State var pointCount: Int = -1
    var body: some View {
        Text("\(pointCount)")
            .onReceive(track.points) { points in
                self.pointCount = points.count
            }
    }
}
