//
// Date+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

//#if canImport(SwiftDate)
//    import SwiftDate
//
//    public extension Date {
//        static func setupSwiftDate() {
//            SwiftDate.defaultRegion = .current
//        }
//         static var zero: Date {
//            Date(timeIntervalSince1970: 0)
//        }
//        var timeIntervalToNow: Double {
//            abs(Date().timeIntervalSince(self))
//        }
//    }
//#else
    public extension Date {
        static func setupSwiftDate() {}

        var timeIntervalToNow: Double {
            abs(Date().timeIntervalSince(self))
        }

        static var formatter = DateFormatter()

        func toFormat(_ format: String) -> String {
            Self.formatter.dateFormat = format
            return Self.formatter.string(from: self)
        }

        static var zero: Date {
            Date(timeIntervalSince1970: 0)
        }
    }
//#endif
