//
//  TwoHandledSlider.swift
//  CombineQuake
//
//  Created by Adrian Bolinger on 4/17/21.
//

import SwiftUI

struct TwoHandledSliderView: View {
    var trackColor = Color.black.opacity(0.5)
    var backgroundTrackColor = Color.black.opacity(0.20)
    var handleColor = Color.red

    @State public var lowValue: CGFloat = 0.0
    @State public var highValue: CGFloat = 1.0

    @State private var cgLowValue: CGFloat = 0.0
    @State private var cgHighValue: CGFloat = UIScreen.main.bounds.width - 60.0

    var totalWidth: CGFloat {
        UIScreen.main.bounds.width - 60.0
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3.0)
                    .fill(backgroundTrackColor)
                    .frame(height: 6)

                Rectangle()
                    .fill(trackColor)
                    .frame(width: self.cgHighValue - self.cgLowValue,
                           height: 6)
                    .offset(x: self.cgLowValue + 18)

                HStack(spacing: 0) {
                    Circle()
                        .fill(handleColor)
                        .shadow(radius: 5)
                        .frame(width: 18,
                               height: 18)
                        .offset(x: self.cgLowValue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.location.x >= 0, value.location.x <= self.cgHighValue {
                                        self.cgLowValue = value.location.x
                                        self.lowValue = cgLowValue / totalWidth
                                    }
                                }
                        )

                    Circle()
                        .fill(handleColor)
                        .shadow(radius: 5)
                        .frame(width: 18,
                               height: 18)
                        .offset(x: self.cgHighValue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.location.x <= totalWidth, value.location.x >= self.cgLowValue {
                                        self.cgHighValue = value.location.x
                                        self.highValue = self.cgHighValue / totalWidth
                                    }
                                }
                        )
                }
            }
            HStack {
                Text(String(format: "%.2f", lowValue))
                    .frame(alignment: .leading)
                Spacer()
                Text(String(format: "%.2f", highValue))
                    .frame(alignment: .trailing)
                    .offset(x: 5)
            }
        }
        .padding()
    }
}

struct TwoHandledSlider_Previews: PreviewProvider {
    static var previews: some View {
        TwoHandledSliderView()
    }
}
