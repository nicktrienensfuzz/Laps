//
// Optional+extension.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

public extension Optional {
    func unwrapped(_ message: String? = nil, path: String = #file, function: String = #function, line: Int = #line) throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none:
            if let message = message {
                throw TuvaError("Failed to unwrap value: \(message) `\(type(of: self))`", path: path, function: function, line: line)
            }
            throw TuvaError("Failed to unwrap value: `\(type(of: self))`", path: path, function: function, line: line)
        }
    }
}
