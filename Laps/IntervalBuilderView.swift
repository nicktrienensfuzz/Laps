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
            Text("Create intervals")

            CustomDraggableComponent()
                .frame(height: 100, alignment: .center)
                .border(Color.green, width: 2)
        }
    }

    struct CustomDraggableComponent: View {
        @State var height: CGFloat = 60
        @State var width: CGFloat = 200

        @State private var maxWidth: Double = 0
        @State private var maxHeight: Double = 60

        @State private var lastTransform: Double = 0

        var body: some View {
            GeometryReader { geo in
                HStack(alignment: .center) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .background(.white)
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            lastTransform = 0
                        }
                        .onChanged { value in
                            // This code allows resizing view min 200 and max to parent view size'
                            let thisTick = value.translation.width - lastTransform
                            lastTransform = value.translation.width
                            width = (width + thisTick).clamped(to: 10 ... geo.size.width)
                        }
                )
            }
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
