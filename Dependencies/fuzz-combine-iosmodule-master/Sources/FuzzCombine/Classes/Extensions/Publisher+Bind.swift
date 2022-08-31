//
//  Publisher+Bind.swift
//  CommunityKiosk
//
//  Created by Nick Trienens on 7/1/20.
//  Copyright © 2020 Nick Trienens. All rights reserved.
//

import Combine
import Foundation

public extension Publisher where Self.Failure == Never {
    
    /// Bind for PassthroughSubject
    /// - Parameter object: stream to send the evnts to
    /// - Returns: AnyCancellable for storage
    func bind(to object: PassthroughSubject<Output, Failure>) -> AnyCancellable {
        sink { value in
            object.send(value)
        }
    }

    /// Bind for PassthroughSubject over optional
    /// - Parameter object: stream to send the evnts to
    /// - Returns: AnyCancellable for storage
    func bind(to object: PassthroughSubject<Output?, Failure>) -> AnyCancellable {
        sink { value in
            object.send(value)
        }
    }

    /// Bind for CurrentValueSubject
    /// - Parameter object: stream to send the evnts to
    /// - Returns: AnyCancellable for storage
    func bind(to object: CurrentValueSubject<Output, Failure>) -> AnyCancellable {
        sink { value in
            object.send(value)
        }
    }
    
   /// Bind for CurrentValueSubject over optional
    /// - Parameter object: stream to send the evnts to
    /// - Returns: AnyCancellable for storage
    func bind(to object: CurrentValueSubject<Output?, Failure>) -> AnyCancellable {
          sink { value in
              object.send(value)
          }
      }
}
