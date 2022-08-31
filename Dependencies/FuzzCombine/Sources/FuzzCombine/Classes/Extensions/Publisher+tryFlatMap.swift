//
//  Publisher+tryFlatMap.swift
//  
//
//  Created by Nicholas Trienens on 1/10/22.
//

import Foundation
import Combine


public extension Publisher {
    func tryFlatMap<Upstream: Publisher>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) throws -> Upstream
    ) -> Publishers.FlatMap<AnyPublisher<Upstream.Output, Error>, Self> {
        flatMap(maxPublishers: maxPublishers) { input -> AnyPublisher<Upstream.Output, Error> in
            do {
                return try transform(input)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(outputType: Upstream.Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
    }
}
