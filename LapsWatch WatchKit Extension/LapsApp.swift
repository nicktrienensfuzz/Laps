//
//  LapsApp.swift
//  LapsWatch WatchKit Extension
//
//  Created by Nicholas Trienens on 8/25/22.
//

import SwiftUI

@main
struct LapsApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
