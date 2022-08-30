//
//  LapsApp.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Base
import BaseWatch
import DependencyContainer
import NavigationStack
import SwiftUI

@main
struct LapsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        ContainerKeys.start()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStackView {
                ContentView()
                    .task {
                        _ = try? await Music.shared.playlists()

                        // Comms.shared.sendMessage(.startActivity)

                        LocalNotificationHelper.shared.requestPermission()

                        await WorkoutTracking.shared.authorizeHealthKit()
                        if WorkoutTracking.shared.isHealthDataAvailable() {
                            WorkoutTracking.shared.observerHeartRateSamples()
                        }
                    }
            }
        }
    }
}

extension Color {
    static let myAppBgColor = Color.gray.opacity(0.2)
}

struct Screen<Content>: View where Content: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            Color.myAppBgColor.edgesIgnoringSafeArea(.all)
            content()
        }
    }
}

struct BackButton: View {
    var body: some View {
        PopView {
            HStack(spacing: 3) {
                Image(systemName: "chevron.backward")
                Text("Back")
                Spacer()
            }
            .padding(.leading, 20)
        }
    }
}
