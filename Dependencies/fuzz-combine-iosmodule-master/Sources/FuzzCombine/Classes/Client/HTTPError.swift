//
//  HTTPError.swift
//  FuzzCombine
//
// Created by Nick Trienens on 3/12/20.
// Copyright © 2020 Fuzzproductions. All rights reserved.
//

import Combine
import Foundation

// MARK: - HTTPError
open class HTTPError: Error, CustomDebugStringConvertible {
    public let errorMessage: String
    public let responseString: String?
    public let statusCode: Int?

    private let filename: String
    private let method: String
    private let line: Int

    public init(_ message: String, response: String? = nil, statusCode: Int? = nil, path: String = #file, function: String = #function, line: Int = #line) {
        filename = path.split(separator: "/").last?.asString ?? path
        method = function
        self.line = line
        self.errorMessage = message
        responseString = response
        self.statusCode = statusCode
    }

    public var debugDescription: String {
        guard let response = responseString else {
            return "\(filename):\(line) - \(method) => \(errorMessage)"
        }
        return "\(filename):\(line) - \(method) => \(errorMessage) [Body]: \(response)"
    }

    public static func invalidStatusCode(_ code: Int, response: String? = nil, urlString: String? = nil,  path: String = #file, function: String = #function, line: Int = #line) -> HTTPError {
        HTTPError.init("Status Code: \(code) outside desired range, url: \(urlString ?? "no Url"), body: \(response ?? "")", statusCode: code, path: path, function: function, line: line)
    }

    public static func noResponse(path: String = #file, function: String = #function, line: Int = #line) -> HTTPError {
        HTTPError.init("No response recieved", path: path, function: function, line: line)
    }
    public static func weakSelfError(path: String = #file, function: String = #function, line: Int = #line) -> HTTPError {
        HTTPError.init("Self deinited and unreachable", path: path, function: function, line: line)
     }
}

// MARK: - Substring Extension
private extension Substring {
    /// convert substring to string inline to allow optional chaining
    var asString: String {
        String(self)
    }
}
