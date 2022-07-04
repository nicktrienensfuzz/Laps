//
//  File.swift
//
//
//  Created by Nicholas Trienens on 12/24/21.
//

import Foundation

// Holder of shared Keys
public enum ContainerKeys {}

public struct KeyedDependency<DependencyType>: DependencyKey {
    public var key: String

    public init(_ key: String, type: DependencyType.Type) {
        self.key = key
        self.type = type
    }

    public var storageKey: String {
        key
    }

    public var type: DependencyType.Type
}
