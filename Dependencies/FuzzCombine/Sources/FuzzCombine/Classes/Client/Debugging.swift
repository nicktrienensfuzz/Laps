//
//  Debugging.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 6/30/20.
//

import Foundation

// Debugging types supported by the Client
public enum Debugging: Equatable {
    case info
    case curlBefore
    case curl
    case completion
    case errors
    case success
    case successLimited(Int)

    var level: Int {
        switch self {
        case .info, .curl, .curlBefore: return 0
        case .errors: return 1
        case .success: return 2
        case .successLimited: return 3
        case .completion: return 4
        }
    }
    var isSuccessfull: Bool {
        switch self {
        case .success, .successLimited:
            return true
        default:
            break
        }
        return false
    }
}

// Accessors for checking debugging values contained in an array
public extension Array where Element == Debugging {
    var containsSuccess: Bool {
        return self.first(where: { $0.isSuccessfull }) != nil
    }

    var limit: Int? {
        if contains(.success) {
            return nil
        }

        let limit = reduce(into: 0) { current, item in
            switch item {
            case .successLimited(let value):
                current += value
            default: break
            }
        }

        return limit == 0 ? nil : limit

    }
}
