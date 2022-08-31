//
//  Combine+Binding.swift
//  FuzzCombine
//
//  Created by Nicholas Trienens on 8/30/21.
//  Copyright © 2021 Fuzzproductions. All rights reserved.
//

import Combine
import Foundation
#if canImport( SwiftUI)

import SwiftUI

@available(watchOS 6.0, *)
public extension CurrentValueSubject {
    func asBinding() -> Binding<Output> {
        Binding<Output> {
            self.value
        } set: { newValue in
            self.value = newValue
        }
    }
}
#endif
