//
//  RoundingMask.swift
//  BlueJayKiosk
//
//  Created by Nicholas Trienens on 8/2/21.
//  Copyright © 2021 Fuzzproductions. All rights reserved.
//

import Foundation
import SwiftUI

public struct RoundingMask: Shape {
    public init(topLeftRadius: CGFloat = 0.0, topRightRadius: CGFloat = 0.0, bottomLeftRadius: CGFloat = 0.0, bottomRightRadius: CGFloat = 0.0) {
        self.topLeftRadius = topLeftRadius
        self.topRightRadius = topRightRadius
        self.bottomLeftRadius = bottomLeftRadius
        self.bottomRightRadius = bottomRightRadius
    }

    public var topLeftRadius: CGFloat = 0.0
    public var topRightRadius: CGFloat = 0.0
    public var bottomLeftRadius: CGFloat = 0.0
    public var bottomRightRadius: CGFloat = 0.0

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let topRight = min(min(topRightRadius, height / 2), width / 2)
        let topLeft = min(min(topLeftRadius, height / 2), width / 2)
        let bottomLeft = min(min(bottomLeftRadius, height / 2), width / 2)
        let bottomRight = min(min(bottomRightRadius, height / 2), width / 2)

        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - topRight, y: 0))
        path.addArc(
            center: CGPoint(x: width - topRight, y: topRight),
            radius: topRight,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: width, y: height - bottomRight))
        path.addArc(
            center: CGPoint(x: width - bottomRight, y: height - bottomRight),
            radius: bottomRight,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: bottomLeft, y: height))
        path.addArc(
            center: CGPoint(x: bottomLeft, y: height - bottomLeft),
            radius: bottomLeft,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addArc(
            center: CGPoint(x: topLeft, y: topLeft),
            radius: topLeft,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )

        return path
    }
}

struct RoundedCornersMask: View {
    var color: Color = .blue
    var tl: CGFloat = 12.0
    var tr: CGFloat = 12.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                let width = geometry.size.width
                let height = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let topRight = min(min(self.tr, height / 2), width / 2)
                let topLeft = min(min(self.tl, height / 2), width / 2)
                let bottomLeft = min(min(self.bl, height / 2), width / 2)
                let bottomRight = min(min(self.br, height / 2), width / 2)

                path.move(to: CGPoint(x: width / 2.0, y: 0))
                path.addLine(to: CGPoint(x: width - topRight, y: 0))
                path.addArc(center: CGPoint(x: width - topRight, y: topRight), radius: topRight, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: width, y: height - br))
                path.addArc(center: CGPoint(x: width - bottomRight, y: height - bottomRight), radius: bottomRight, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bottomLeft, y: height))
                path.addArc(center: CGPoint(x: bottomLeft, y: height - bottomLeft), radius: bottomLeft, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: topLeft, y: topLeft), radius: topLeft, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
