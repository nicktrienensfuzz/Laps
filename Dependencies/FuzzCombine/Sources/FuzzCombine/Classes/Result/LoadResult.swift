//
//  LoadResult.swift
//   FuzzCombine
//
//  Created by Nicholas Trienens on 4/25/18.
//

import Foundation

/// The state of a data load.
///
/// - loading: A load is in progress.
/// - success: data has been loaded.
/// - error: An error occurred when loading.
/// - notStarted: No load is in progress. This represents both "a load is complete" and "a load has not started."
public enum LoadResult<T>: Equatable {
    case success(_ value: T)
    case loading
    case error(_ error: Error)
    case notStarted

    public var active: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    public var value: T? {
        switch self {
        case let .success(value):
            return value
        default:
            return nil
        }
    }

    public var loaded: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case let .error(error):
            return error
        default:
            return nil
        }
    }

    public static func == (lhs: LoadResult<T>, rhs: LoadResult<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.notStarted, .notStarted),
             (.success, .success),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}

func != (lhs: LoadResult<Any>, rhs: LoadResult<Any>) -> Bool {
    return !(lhs == rhs)
}
