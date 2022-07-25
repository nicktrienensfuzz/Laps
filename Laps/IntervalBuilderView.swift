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

    struct CustomDraggableComponent: View {
        init(changed: @escaping (Double) -> Void = { _ in }) {
            self.changed = changed
        }

        var changed: (Double) -> Void

        @State private var height: CGFloat = 60
        @State private var width: CGFloat = 200

        @State private var maxWidth: Double = 0
        @State private var maxHeight: Double = 60

        @State private var lastTransform: Double = 0

        var body: some View {
            GeometryReader { geo in
                HStack(alignment: .center, spacing: 0) {
                    Rectangle()
                        .fill(Color.red.opacity(0.7))
                        .frame(minWidth: width,
                               maxWidth: width,
                               minHeight: height,
                               maxHeight: height)
                    Spacer(minLength: 0)
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
                            width = (width + thisTick).clamped(to: 0 ... geo.size.width)

                            changed(width / geo.size.width)
                        }
                )
            }
            .frame(height: height)
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
