//
//  HeartRateZones.swift
//  Laps
//
//  Created by Nicholas Trienens on 1/23/23.
//

import SwiftUI

struct HeartRateZones: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    // HRDP extraction algorithm
      func zoneExtraction() {

          // Calculation of max HR as per literature
          let maxHeartRate = 220.0 - Double(50) // Default age to 60
        
      }
}

struct HeartRateZones_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateZones()
    }
}
