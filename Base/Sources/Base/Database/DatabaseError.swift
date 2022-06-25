//
// UpdaterError.swift
// Updater
//
// Created by Nicholas Trienens on 5/14/20.
// Copyright © 2020 Nick Trienens. All rights reserved.

import Foundation

struct DatabaseError: Error, CustomDebugStringConvertible, CustomStringConvertible, LocalizedError {
    let message: String
    private let filename: String
    private let method: String
    private let line: Int

    init(_ message: String, path: String = #file, function: String = #function, line: Int = #line) {
        filename = path.split(separator: "/").last?.asString ?? path
        method = function
        self.line = line
        self.message = message
    }

    var debugDescription: String { "\(filename):\(line) - \(method) => \(message)" }
    var description: String { "\(filename):\(line) - \(method) => \(message)" }
    var errorDescription: String? { debugDescription }
    // MARK: Common errors

    static func deinitedSelf(path: String = #file, function: String = #function, line: Int = #line) -> DatabaseError {
        .init("Deinited Self", path: path, function: function, line: line)
    }

    static func notImplemented(path: String = #file, function: String = #function, line: Int = #line) -> DatabaseError {
        .init("Not Implemented \(function)", path: path, function: function, line: line)
    }
}

// MARK: - Substring Extension
extension Substring {
    var asString: String {
        String(self)
    }
}
