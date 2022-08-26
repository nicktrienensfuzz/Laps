//
// Logger.swift
// NapperCast
//
// Created by Nicholas Trienens on 5/14/20.
// Copyright © 2020 Nick Trienens. All rights reserved.

import Foundation
import os
import TuvaCore

public func tryLog(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        osLog(error)
    }
}

public let kBundleId = "Laps"

public func osLog(_ message: String, line: Int = #line, path: String = #file, as type: OSLogType = .error, bundleId: String = kBundleId) {
    let file = path.split(separator: "/").last?.asString ?? path

    if #available(iOS 12.0, *) {
        let log = OSLog(subsystem: bundleId, category: "C")
        os_log(type, log: log, "%{public}@", "[\(file):\(line)] " + message)
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss.SSS"
        let timeString = formatter.string(from: Date())
        osLog("[\(timeString)][\(file):\(line)] " + message)
    }
}

public func osLog(_ object: Any?, line: Int = #line, path: String = #file, as type: OSLogType = .error, bundleId: String = kBundleId) {
    if let object = object {
        osLog(object, line: line, path: path, as: type, bundleId: bundleId)
    } else {
        osLog("NIL", line: line, path: path, as: type, bundleId: bundleId)
    }
}

public func osLog(_ object: Any, line: Int = #line, path: String = #file, as type: OSLogType = .error, bundleId: String = kBundleId) {
    let file = path.split(separator: "/").last?.asString ?? path

    if #available(iOS 12.0, *) {
        let log = OSLog(subsystem: bundleId, category: "C")
        os_log(type, log: log, "%{public}@", "[\(file):\(line)] \(object)")
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss.SSS"
        let timeString = formatter.string(from: Date())
        osLog("[\(timeString)][\(file):\(line)]  \(object)")
    }
}

public func signPost(path: String = #file, function: String = #function, line: Int = #line) {
    osLog("@\(function)", line: line, path: path)
}

public func logRetainCount(_ object: Any, path: String = #file, line: Int = #line) {
    osLog("RC \(CFGetRetainCount(object as CFTypeRef))", line: line, path: path)
}
