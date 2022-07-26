//
//  IntervalBuilderView.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/4/22.
//

import Base
import ComposableArchitecture
import SwiftUI

struct IntervalBuilderView: View {
    var body: some View {
        VStack {
            CustomDraggableComponent(changed: {
                osLog($0)
            })
            .border(Color.green, width: 2)
            .padding(.horizontal, 10)
        }
    }
}

struct IntervalBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalBuilderView()
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
