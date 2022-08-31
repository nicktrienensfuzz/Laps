//
// String+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import CommonCrypto
import Foundation

public extension String {
    var uppercasedFirst: String {
        prefix(1).capitalized + dropFirst()
    }

    var lowercasedFirst: String {
        prefix(1).lowercased() + dropFirst()
    }

    var camelize: String {
        guard !isEmpty else {
            return self
        }

        let parts = components(separatedBy: CharacterSet.alphanumerics.inverted)

        if let first = parts.first?.lowercasedFirst {
            let rest = parts.dropFirst().map { $0.uppercasedFirst }
            return ([first] + rest).joined(separator: "")
        }

        return self
    }

    func emptyAsNil() -> String? {
        if isEmpty {
            return nil
        }
        return self
    }

    var sha256: String {
        let data = Data(utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    /// Whether or not the string represents a valid email.
    var isEmail: Bool {
        let regex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }

    // MARK: - CharacterSet methods

    static var emailAcceptableCharacters: CharacterSet {
        let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~@."
        return CharacterSet(charactersIn: acceptableCharacters)
    }

    static var nameAcceptableCharacters: CharacterSet {
        let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return CharacterSet(charactersIn: acceptableCharacters)
    }

    func contains(oneOf: CharacterSet) -> Bool {
        let filtered = components(separatedBy: oneOf).joined(separator: "")
        return filtered != self
    }

    func trim(any: CharacterSet) -> String {
        var cleanedString = self
        if let first = first, String(first).contains(oneOf: any) {
            cleanedString = removing(first: 1)
        }
        if let last = cleanedString.last, String(last).contains(oneOf: any) {
            cleanedString = cleanedString.removing(last: 1)
        }
        return cleanedString
    }

    func removing(last characters: UInt) -> String {
        prefix(count - Int(characters)).asString
    }

    func removing(first characters: UInt) -> String {
        suffix(count - Int(characters)).asString
    }

    func removing(occurances target: String) -> String {
        replacingOccurrences(of: target, with: "")
    }

    // MARK: - Data Helpers

    var asData: Data? {
        data(using: .utf8)
    }

    func data() throws -> Data {
        if let ret = data(using: .utf8) {
            return ret
        }
        throw TuvaError("Conversion to Data failed")
    }

    // MARK: - className method

    /// get the class name as a string
    static func classname(_ object: Any) -> String {
        var className: String = String(describing: object)
        if className.hasPrefix("<") {
            let classNameSlice = className.dropFirst()
            className = String(classNameSlice.prefix(upTo: classNameSlice.firstIndex(of: ":") ?? classNameSlice.endIndex))
        }
        return className
    }
}

#if os(iOS) 
    import UIKit

    public extension String {
        var imageNamed: UIImage? {
            UIImage(named: self)
        }

        @available(iOS 13.0, *)
        var systemNamed: UIImage? {
            UIImage(systemName: self)
        }
    }
#endif

// MARK: - Substring Extension

public extension Substring {
    var asString: String {
        String(self)
    }
}
