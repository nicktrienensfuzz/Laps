//
//  ObservableOutputBuilder.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 9/11/20.
//  Copyright © 2020 Fuzzproductions. All rights reserved.
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI

/// SwiftUI Compatible Version
/// Conformance to this Protocol is a signal to the developer
/// that this ViewModel uses Input/Output types for bindings
/// output is built Via a `buildOutput` method which takes interaction arguments
public protocol ObservableOutputBuilder {
    associatedtype Input
    associatedtype Output: ObservableObject
    func buildOutput(_ input: Input) -> Output
}

#endif
