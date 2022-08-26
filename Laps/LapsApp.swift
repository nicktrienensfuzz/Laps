//
//  LapsApp.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import BaseWatch
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

                    Comms.shared.sendMessage(.startActivity)

                    LocalNotificationHelper.shared.requestPermission()

                    await WorkoutTracking.shared.authorizeHealthKit()
                    if WorkoutTracking.shared.isHealthDataAvailable() {
                        WorkoutTracking.shared.observerHeartRateSamples()
                    }
                }
        }
    }
}
