//
//  Just+Extension.swift
//  CommunityKiosk
//
//  Created by Nick Trienens on 6/26/20.
//  Copyright © 2020 Nick Trienens. All rights reserved.
//

import Combine
import Foundation

public extension Just {
    // return a new  typeearased Just with Failure convertted to Error
    static func errorable(_ value: Output) -> AnyPublisher<Output, Error> {
        Just(value)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // return a new  typeearased Just
    static func any(_ value: Output) -> AnyPublisher<Output, Never> {
        Just(value)
            .eraseToAnyPublisher()
    }
}
