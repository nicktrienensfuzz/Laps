//
//  AppDelegate.swift
//  Laps
//
//  Created by Nicholas Trienens on 6/25/22.
//

import AVFoundation
import Base
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        osLog("Your code here")

        tryLog {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        }

        return true
    }
}
