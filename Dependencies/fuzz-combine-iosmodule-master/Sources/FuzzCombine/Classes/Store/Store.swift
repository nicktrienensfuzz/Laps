//
// Store.swift
// FuzzCombine
//
// Created by Nicholas Trienens on 5/2/20.
// Copyright © 2020 FuzzProductions, LLC. All rights reserved.

import Combine
import Foundation

/// this is a small Aggregator that takes Actions and applies them to a current value
/// this is an early version of PointFree.co's store as a stand alone class
///
@available(watchOS 6.0, *)
public final class Store<Value, Action>: ObservableObject {
    private let reducer: (inout Value, Action) -> Void
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?

    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        value = initialValue
    }

    public func send(_ action: Action) {
        reducer(&value, action)
    }
}
