//
//  Fail+Extension.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 8/13/20.
//

import Combine
import Foundation

public extension Fail {
    static func any(_ error: Error) -> AnyPublisher<Output, Error> {
        Fail<Output, Error>(error: error)
            .eraseToAnyPublisher()
    }
}
