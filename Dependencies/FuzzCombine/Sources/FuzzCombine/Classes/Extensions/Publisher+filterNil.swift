//
//  Publisher+filterNil.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 10/29/20.
//

import Foundation
import Combine

public extension Publisher where Self.Output: OptionalType {
    func filterNil() -> AnyPublisher<Self.Output.Wrapped, Self.Failure> {
        return flatMap { element -> AnyPublisher<Self.Output.Wrapped, Self.Failure> in
            guard let value = element.value else {
                return Empty(completeImmediately: false).setFailureType(to: Self.Failure.self).eraseToAnyPublisher()
            }
            return Just(value).setFailureType(to: Self.Failure.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}
