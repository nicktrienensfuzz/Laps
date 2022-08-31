//
// TuvaError.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

open class TuvaError: AlertableError, CustomDebugStringConvertible {
    public let message: String
    private let filename: String
    private let method: String
    private let line: Int

    public init(_ message: String, path: String = #file, function: String = #function, line: Int = #line) {
        if let file = path.split(separator: "/").last {
            filename = String(file)
        } else {
            filename = path
        }
        method = function
        self.line = line
        self.message = message
    }

    open var debugDescription: String { "\(filename):\(line) - \(method) => \(message)" }
}
