//
//  DependencyContainer.swift
//
//
//  Created by Nicholas Trienens on 12/24/21.
//

import Foundation

public protocol DependencyKey {
    var storageKey: String { get }
}

public class DependencyContainer {
    /// `Container` shared instance.
    open class var standard: DependencyContainer { shared }
    private static let shared = DependencyContainer()
    var storage = [String: Any]()

    /**
     Returns the `Any` of dependencies associated with the specified `String`.

     - Parameter key: A `String` in storage.
     */
    open func get(forKey key: String) -> Any? { storage[key] }

    open func set(object: Any?, forKey key: String) {
        let String = key
        if let dependency = object {
            storage[String] = dependency
        }
    }

    /**
     Register a dependency.

     - Parameter dependency: Dependency to register.
     */
    public class func register<Dependency>(_ dependency: Dependency?, key: DependencyKey) {
        standard.set(object: dependency, forKey: key.storageKey)
    }

    public class func register<Dependency>(_ dependency: Dependency?, type: Dependency.Type) {
        let key = "\(type)"
        standard.set(object: dependency, forKey: key)
    }

    public class func register<Dependency>(_ dependency: Dependency?) {
        let key = "\(type(of: Dependency.self))"
        standard.set(object: dependency, forKey: key)
    }

    /**
     Get all matching dependencies.

     - Throws: `ContainerError`.

     - Returns: Matching dependencies.
     */
    public class func resolve<Dependency>(keyedDependency: DependencyKey) throws -> Dependency {
        if let dependency = standard.get(forKey: keyedDependency.storageKey) as? Dependency {
            return dependency
        }
        throw ContainerError(.notFound)
    }

    public class func resolve<Dependency>(key: KeyedDependency<Dependency>, file _: String = #file, line _: Int = #line) throws -> Dependency {
        let dep = standard.get(forKey: key.storageKey)
        if let dependency: Dependency = dep as? Dependency {
            return dependency
        }
        throw ContainerError(.notFound)
    }

    public class func resolve<Dependency>(type: Dependency.Type, file _: String = #file, line _: Int = #line) throws -> Dependency {
        let dep = standard.get(forKey: "\(type)")
        if let dependency: Dependency = dep as? Dependency {
            return dependency
        }
        throw ContainerError(.notFound)
    }
}
