//
//  LapsApp.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import SwiftUI
import Base
import DependencyContainer
@main
struct LapsApp: App {
    
    init() {
        ContainerKeys.start()

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
    }
}
