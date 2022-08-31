//
//  Publisher+asyncMap.swift
//  
//
//  Created by Nicholas Trienens on 1/10/22.
//

import Foundation
import Combine

#if compiler(>=5.5) && canImport(_Concurrency)

public extension Publisher {
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    func tryAsyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

#endif
