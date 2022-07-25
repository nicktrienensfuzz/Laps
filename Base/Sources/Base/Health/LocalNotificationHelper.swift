//
//  LocalNotificationHelper.swift
//  ElecDemo
//
//  Created by NhatHM on 8/12/19.
//  Copyright © 2019 GST.PID. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

public class LocalNotificationHelper: NSObject, UNUserNotificationCenterDelegate {
    public static var shared = LocalNotificationHelper()
    override init() {
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    public func requestPermission() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Granted")
            } else {
                print("Not Granted")
            }
        }
    }

    public func fireHeartRate(_ heartRate: Double) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Current heart rate"
        content.body = "Heart Reate = \(heartRate)"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void
    ) {
//        osLog(notification)
//        osLog(notification.request.content)

        if let userId = notification.request.content.userInfo["user_id"] as? Int {
            osLog(userId)

        } else if let userIdString = notification.request.content.userInfo["user_id"] as? String, let userId = Int(userIdString) {
            osLog(userId)
        }

        completionHandler([])
        // completionHandler([.banner])
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive _: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let appState: String
        switch UIApplication.shared.applicationState {
        case .active:
            appState = "active"
        case .inactive:
            appState = "inactive"
        case .background:
            appState = "background"
        @unknown default:
            appState = "unknown"
        }
        osLog("user tapped the notification bar when the app is in \(appState)")

        // processIncomingNotification(response.notification)

        completionHandler()
    }
}
