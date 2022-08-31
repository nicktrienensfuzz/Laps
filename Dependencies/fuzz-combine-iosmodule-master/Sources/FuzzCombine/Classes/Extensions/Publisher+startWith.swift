//
//  Publisher+startWith.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 10/30/20.
//

import Foundation
import Combine

public extension Publisher {
    // Creates a merge with the value passed in as the firt item in the stream
    //
    //Just(4)
    //    .startWith(5)
    //    .sink { print($0) }
    //    .store(in: &publisherStorage)
    //
    // receive value: (5)
    // receive value: (4)
    // even when the source Publisher is posibly going to return imedaitly this will start the stream with the passed in value
    
    /// Creates a merge with the value passed in as the firt item in the stream
    /// - Parameter value: first value on the stream
    /// - Returns: Publishers.Merge<output, Failure> with an instantaniou value of value
    func startWith(_ value: Output) -> Publishers.Merge<Result<Self.Output, Self.Failure>.Publisher, Self> {
        Publishers.Merge(
            Just(value).setFailureType(to: Failure.self),
            self
        )
    }
}
