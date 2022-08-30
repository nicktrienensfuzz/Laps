//
//  AppDelegate.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/25/22.
//

import AVFoundation
import Base
import BaseWatch
import Combine
import DependencyContainer
import Foundation
import Logger
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private var publisherStorage = Set<AnyCancellable>()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        tryLog {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        }

        Comms.shared.heartRateValue.didUpdate
            .asyncMap { hr in
                try? await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in
                    let trackId = Location.shared.track.value?.id

                    let point = HeartRatePoint(
                        timestamp: hr.timestamp,
                        heartRate: hr.heartRate,
                        trackId: trackId
                    )
                    try point.save(db)
                    osLog("Saved HeartRate: \(point.toSwift())")
                }
            }
            .sink { _ in
            }
            .store(in: &publisherStorage)

        return true
    }
}
