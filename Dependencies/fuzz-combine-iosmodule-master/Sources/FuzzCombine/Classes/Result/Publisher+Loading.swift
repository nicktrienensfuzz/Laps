//
//  Publisher+Loading.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 10/16/20.
//

import Foundation
import Combine

@available(watchOS 6.0, *)
public extension Publisher {
    func asLoadResult() -> AnyPublisher<LoadResult<Output>, Never> {
        map { element -> LoadResult<Output> in
            .success(element)
        }
        .catch { error -> AnyPublisher<LoadResult<Output>, Never> in
            Just(.error(error)).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func asLoadStatus() -> AnyPublisher<LoadStatus, Never> {
        map { _ -> LoadStatus in
            .success
        }
        .catch { error -> AnyPublisher<LoadStatus, Never> in
            Just(.error(error)).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

