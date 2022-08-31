//
//  Publisher+onOutput.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 10/30/20.
//

import Foundation
import Combine

// simple invokation of handleEvents
public extension Publisher {
    /// calls action for every output passed through this stream
    func onOutput(_ action: @escaping (Output) ->() ) -> AnyPublisher<Output,Failure> {
        handleEvents( receiveOutput: action )
            .eraseToAnyPublisher()
    }
}
