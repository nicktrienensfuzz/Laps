//
// UIDevice+Battery.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation
#if canImport(UIKit) && !os(watchOS)
    import UIKit
 
    extension UIDevice.BatteryState: CustomStringConvertible {
        public var description: String {
            switch self {
            case .unknown:
                return "unknown"
            case .unplugged:
                return "unplugged"
            case .charging:
                return "charging"
            case .full:
                return "full"
        @unknown default:
                return "unknown"
            }
        }
    }
#endif
