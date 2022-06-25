//
//  File.swift
//  
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Foundation
import AsyncLocationKit
import DependencyContainer

public extension ContainerKeys {
    static let location = KeyedDependency("Location", type: Location.self)

    static func start() {
        DependencyContainer.register(Location(), key: ContainerKeys.location)
        DependencyContainer.register(AppDatabase(), key: ContainerKeys.database)
        DependencyContainer.register(Music(), key: ContainerKeys.music)

    }
}


public actor Location {
    
    public static let shared = Location()
    
    public init() {
        
    }
    
    let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)

    public func request() async throws {
        let permission = await self.asyncLocationManager.requestAuthorizationAlways()
        dump(permission)
    }
    
    public func startUpdatingLocation() async -> LocationStream {
        await asyncLocationManager.startUpdatingLocation()
    }
    
}
