//
//  LoadStatus.swift
//  FuzzCombine
//
//  Created by Nicholas Trienens on 4/25/18.
//

import Foundation

/// The state of a data load.
///
/// - loading: A load is in progress.
/// - error: An error occurred when loading.
/// - success: a load has completed
/// - notStarted: No load is in progress. This represents both "a load has not started."
public enum LoadStatus: Equatable {
    case loading
    case error(_ error: Error)
    case success
    case notStarted

    public var active: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    public var started: Bool {
        switch self {
        case .notStarted:
            return false
        default:
            return true
        }
    }

    public var complete: Bool {
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
}

public func == (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading),
         (.notStarted, .notStarted),
         (.error, .error),
         (.success, .success):
        return true
    default:
        return false
    }
}

func != (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    return !(lhs == rhs)
}
