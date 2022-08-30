//
//  MapView2.0.swift
//  Laps
//
//  Created by Nicholas Trienens on 8/29/22.
//

import Base
import FuzzCombine
import MapKit
import SwiftUI

extension CircularPOI: Identifiable {}

struct MapView2_0: View {
    @ObservedObject var region: Reference<MKCoordinateRegion>
    // @ObservedObject var region: Reference<MKCoordinateRegion>

    var body: some View {
        Map(coordinateRegion: region.asBinding(),
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: .constant(.follow),
            annotationItems: [CircularPOI]()) { place in
                MapMarker(coordinate: place.coordinate)
            }
    }
}

// struct MapView2_0_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView2_0()
//    }
// }
