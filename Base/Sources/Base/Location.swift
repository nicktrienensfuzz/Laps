//
//  File.swift
//  
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Foundation
import AsyncLocationKit

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
