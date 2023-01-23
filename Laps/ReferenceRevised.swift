//
//  ReferenceRevised.swift
//  Laps
//
//  Created by Nicholas Trienens on 9/30/22.
//

import Foundation
//
//  Repository.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 10/30/20.
//  Copyright © 2020 Fuzzproductions. All rights reserved.
//

import Combine
import Foundation
import FuzzCombine
#if canImport( SwiftUI)
import SwiftUI
#endif

// This interface allows a value type to be passed as a reference
// and allows for easy access to the wrapped Value's properties
@dynamicMemberLookup
open class Reference<Value>: ObservableObject {
    open var value: Value {
        willSet {
            willUpdate.send(())
        }
        didSet {
            updated.send(())
        }
    }
    
    fileprivate var updated = PassthroughSubject<Void, Never>()
    open var didUpdate: AnyPublisher<Value, Never> {
        updated
            .flatMap{ [weak self] in
                guard let self = self else  {
                    return Empty<Value, Never>()
                        .eraseToAnyPublisher()
                }
                return Just.any(self.value)
            }
            .eraseToAnyPublisher()
    }
    
    open var currentValueWithUpdates: AnyPublisher<Value, Never> {
        updated
            .flatMap{ [weak self] in
                guard let self = self else  {
                    return Empty<Value, Never>()
                        .eraseToAnyPublisher()
                }
                return Just.any(self.value)
            }
            .prepend(value)
            .eraseToAnyPublisher()
    }
    
    fileprivate var willUpdate = PassthroughSubject<Void, Never>()
    open var objectWillChange: AnyPublisher<Void, Never> {
        willUpdate
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public init(value: Value) {
        self.value = value
    }
    deinit { print("Reference \(self) deinit") }
    
    open func update(value: Value) {
        willUpdate.send(())
        self.value = value
        updated.send(())
    }
    
    open subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        value[keyPath: keyPath]
    }
    
#if canImport( SwiftUI)
    open func asBinding() -> Binding<Value> {
        Binding<Value> {
            self.value
        } set: { [weak self] newValue in
            self?.value = newValue
        }
    }
#endif
}

open class BoundReference<Value>: Reference<Value> {
    var publisherStorage = Set<AnyCancellable>()
    open func bind(to: AnyPublisher<Value, Never>) {
        to.weakAssign(to: \.value, on: self)
            .store(in: &publisherStorage)
    }
    
    open func drive(on subject: PassthroughSubject<Value, Never>) {
        didUpdate.bind(to: subject)
            .store(in: &publisherStorage)
    }
    
    open func onChange( _ block: @escaping (Value) -> Void) {
        didUpdate.sink { value in
            block(value)
        }
        .store(in: &publisherStorage)

    }
    
}

open class MutableReference<Value>: Reference<Value> {
    open subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get {
            value[keyPath: keyPath]
        }
        set {
            value[keyPath: keyPath] = newValue
            updated.send(())
        }
    }
}


// https://www.swiftbysundell.com/articles/combine-self-cancellable-memory-management/

public extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
