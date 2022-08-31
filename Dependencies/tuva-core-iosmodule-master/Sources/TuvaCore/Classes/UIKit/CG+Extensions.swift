//
// CG+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation
#if os(macOS)
    import AppKit
#endif

#if !os(macOS)
    import UIKit
#endif

public extension CGPoint {
    func scaled(by size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }
}

public extension CGSize {
    func scaled(by size: CGSize) -> CGSize {
        CGSize(width: width * size.width, height: height * size.height)
    }
}

public extension CGRect {
    init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    var bounds: CGRect { CGRect(x: 0, y: 0, width: size.width, height: size.height) }

    func sizeDivided(by: CGFloat) -> CGRect {
        CGRect(x: origin.x, y: origin.y, width: size.width / by, height: size.height / by)
    }

    func sizeMultiplied(times: CGFloat) -> CGRect {
        CGRect(x: origin.x, y: origin.y, width: size.width * times, height: size.width * times)
    }

    func offset(by: CGPoint) -> CGRect {
        CGRect(x: origin.x + by.x, y: origin.y + by.y, width: size.width, height: size.height)
    }

    func scaled(_ scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale,
                      width: size.width * scale, height: size.height * scale)
    }
}

public extension CGSize {
    func inset(x: CGFloat, y: CGFloat) -> CGSize {
        CGSize(width: width - x, height: height - y)
    }

    func expand(x: CGFloat, y: CGFloat) -> CGSize {
        CGSize(width: width + x, height: height + y)
    }

    func contract(x: CGFloat, y: CGFloat) -> CGSize {
        CGSize(width: width - x, height: height - y)
    }

    func multiplied( by times: CGFloat) -> CGSize {
        CGSize(width: width * times, height: height * times)
    }
    
    func divided( by divisor: CGFloat) -> CGSize {
        guard divisor != 0 else {
            return self
        }
        return CGSize(width: width / divisor, height: height / divisor)
    }
    
    var asRect: CGRect { CGRect(x: 0, y: 0, width: width, height: height) }
}
