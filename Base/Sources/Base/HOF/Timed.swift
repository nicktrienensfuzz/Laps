//
//  File.swift
//  
//
//  Created by Nicholas Trienens on 1/4/23.
//

import Foundation
import Logger

public func timed<T>(line: UInt = #line, file: String = #file, block: @escaping () -> T) -> T {
    let startDate = Date()
    defer {
        let filename = file.split(separator: "/").last?.asString ?? file
        osLog("Call \(filename):\(line) Took: \(startDate.timeIntervalToNow)")
    }
    return block()
}


public func timed<T>(line: UInt = #line, file: String = #file, block: @escaping () async throws -> T) async throws -> T {
    let startDate = Date()
    defer {
        let filename = file.split(separator: "/").last?.asString ?? file
         osLog("Call \(filename):\(line) Took: \(startDate.timeIntervalToNow)")
    }
    return try await block()
}
