//
//  Combine+TimedRemoveDuplicates.swift
//  FuzzCombine
//
//  Created by Nicholas Trienens on 5/10/22.
//  Copyright © 2022 Fuzzproductions. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    
    public func removeDuplicates(for timeInterval: TimeInterval, by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> AnyPublisher<Output,Failure> {
        
        map { value -> (Output, Date) in
            (value, Date())
        }
        .removeDuplicates(by: { old, new in
            // exit early if the data has moved out of the timeInterval range.
            let timeSince = abs(old.1.timeIntervalSince(new.1))
            if timeSince > timeInterval {
                return false
            }
            return predicate(old.0, new.0)
        })
        .map { value, _ -> Output in
            return value
        }
        .eraseToAnyPublisher()
    }
}
