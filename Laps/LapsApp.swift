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
//                    if await !Music.shared.isPlaying() {
//                        await Music.shared.test()
//                    }
                    _ = try? await Music.shared.playlists()

                    LocalNotificationHelper.shared.requestPermission()
//                    WorkoutTracking.shared.authorizeHealthKit()
//                    if WorkoutTracking.shared.isHealthDataAvailable() {
//                        WorkoutTracking.shared.observerHeartRateSamples()
//                    }
                }
        }
    }
}
