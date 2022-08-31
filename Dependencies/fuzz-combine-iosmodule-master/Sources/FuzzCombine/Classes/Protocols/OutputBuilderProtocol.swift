//
//  OutputBuilderProtocol.swift
//  FuzzCombine
//
// Created by Nick Trienens on 3/12/20.
// Copyright © 2020 Fuzzproductions. All rights reserved.
//

import Foundation

/// Conformance to this Protocol is a signal to the developer
/// that this ViewModel uses Input/Output types for bindings
/// output is built Via a `buildOutput` method which takes interaction arguments
public protocol OutputBuilder {
    associatedtype Input
    associatedtype Output
    func buildOutput(_ input: Input) -> Output
}
