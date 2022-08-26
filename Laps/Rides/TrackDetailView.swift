//
//  TrackDetailView.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/6/22.
//

import Base
import Logger
import MapKit
import SwiftUI

struct TrackDetailView: View {
    let track: Track
    @State var points = [TrackPoint]()

    init(track: Track) {
        self.track = track
    }

    var body: some View {
        osLog("points: \(points.count)")
        return VStack {
            MapView(
                region: MKCoordinateRegion(fittingCoordinates: points.map(\.coordinate)) ?? MKCoordinateRegion.washington,
                lineCoordinates: points.map(\.coordinate),
                circleTriggerRegions: []
            ) { loc in
                osLog(loc)
            }
        }
        .onReceive(track.points.removeDuplicates(), perform: { newTracks in
            osLog(newTracks.count)
            points = newTracks
        })
        .navigationTitle(track.id.prefix(8))
    }
}

// struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailView()
//    }
// }
