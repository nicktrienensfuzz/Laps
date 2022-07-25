//
//  WaitingDots.swift
//  Laps
//
//  Created by Nicholas Trienens on 7/23/22.
//

import CoreMotion
import Foundation
import SwiftUI

struct WaitingDots: View {
    @State private var y: CGFloat = 0

    var body: some View {
        HStack {
            Dot(y: y)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0), value: y)
            Dot(y: y)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.2), value: y)
            Dot(y: y)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.4), value: y)
        }
        .onAppear { y = -4 }
        .padding()
    }
}

struct Dot: View {
    var y: CGFloat

    var body: some View {
        Circle()
            .frame(width: 8, height: 8, alignment: .center)
            .opacity(y == 0 ? 0.1 : 1)
            .offset(y: y)
            .foregroundColor(.gray)
    }
}

struct WaitingDots_Previews: PreviewProvider {
    static var previews: some View {
        WaitingDots()
    }
}

// set a default linear gradient
extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// create our neumorphic style
extension View {
    func neumorphicStyle() -> some View {
        background(Color(.sRGB, white: 0.90, opacity: 1))
            .cornerRadius(10)
            .padding(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
    }
}

struct ParallaxMotionModifier: ViewModifier {
    @ObservedObject var manager = MotionManager()
    var magnitude: Double = 2

    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
    }
}

class MotionManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0

    private var motionManager: CMMotionManager

    init() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1 / 60
        motionManager.startDeviceMotionUpdates(to: .main) { motionData, error in
            guard error == nil else {
                print(error!)
                return
            }

            if let motionData = motionData {
                self.pitch = motionData.attitude.pitch
                self.roll = motionData.attitude.roll
            }
        }
    }
}
