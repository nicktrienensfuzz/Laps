//
//  LapsApp.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import DependencyContainer
import SwiftUI
@main
struct LapsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        ContainerKeys.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await Music.shared.test()
                }
        }
    }
}
