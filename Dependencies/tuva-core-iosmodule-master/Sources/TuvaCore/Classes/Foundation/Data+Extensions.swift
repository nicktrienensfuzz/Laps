//
// Data+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

public extension Data {
    func decodeArray<T: Decodable>(decoder: JSONDecoder? = nil) throws -> [T] {
        let usedDecoder: JSONDecoder
        if let decoder = decoder {
            usedDecoder = decoder
        } else {
            usedDecoder = JSONDecoder()
            usedDecoder.dateDecodingStrategy = .iso8601
        }
        return try usedDecoder.decode([T].self, from: self)
    }
    
    func decode<T: Decodable>(decoder: JSONDecoder? = nil) throws -> T {
        let usedDecoder: JSONDecoder
        if let decoder = decoder {
            usedDecoder = decoder
        } else {
            usedDecoder = JSONDecoder()
            usedDecoder.dateDecodingStrategy = .iso8601
        }
        return try usedDecoder.decode(T.self, from: self)
    }

    func toString() -> String? {
        String(data: self, encoding: .utf8)
    }

    func toString() throws -> String {
        if let ret = String(data: self, encoding: .utf8) {
            return ret
        }
        throw TuvaError("Couldn't Convert Data to String")
    }

    ///  a hex string representation of self
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    /// Failable initalizer for converting a hex string to Data
    ///
    /// - Parameter hex: a string representing data
    init?(hex: String) {
        let length = hex.count / 2
        var data = Data(capacity: length)
        for i in 0 ..< length {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j ..< k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
