//
//  File.swift
//
//
//  Created by Nicholas Trienens on 8/25/22.
//

import Combine
import Communicator
import DependencyContainer
import Foundation
import FuzzCombine
import Logger

public extension ContainerKeys {
    static var commsKey = KeyedDependency("comms", type: Comms.self)
}

public class Comms {
    public struct HeartRatePoint {
        public let timestamp: Date
        public let heartRate: Double
    }

    public let actions: PassthroughSubject<Action, Never> = .init()
    public static let shared = Comms()

    public let heartRateValue: Reference<HeartRatePoint> = .init(value: HeartRatePoint(timestamp: .distantPast, heartRate: 0))

    public init() {
        osLog("boot watch Comms")
        Communicator.State.observe { state in
            osLog("state: \(state)")
        }

        ImmediateMessage.observe { message in
            osLog(message)
            guard message.identifier == "actions" else { return }
            guard let action = Action(rawValue: message.content["action"] as? String ?? "") else { return }
            self.actions.send(action)
        }

        InteractiveImmediateMessage.observe { message in
            guard message.identifier == "actions" else { return }
            let replyMessage = ImmediateMessage(identifier: "response", content: ["reply": "message"])
            osLog("Message received! \(message)")
            guard let action = Action(rawValue: message.content["action"] as? String ?? "") else { return }
            osLog(action)
            self.actions.send(action)
            message.reply(replyMessage)

            if let heartRate = message.content["heartRate"] as? Double, let timestamp = message.content["timestamp"] as? Date {
                let hr = HeartRatePoint(timestamp: timestamp, heartRate: heartRate)
                osLog(hr)
                self.heartRateValue.value = hr
            }
        }
    }

    public enum Action: String {
        case startActivity
        case stopActivity
        case update
    }

    public func sendMessage(_ action: Action, heartRate: Double = 0, timestamp: Date = .distantPast) {
        let message = InteractiveImmediateMessage(
            identifier: "actions",
            content: ["action": action.rawValue,
                      "heartRate": heartRate,
                      "timestamp": timestamp]
        ) {
            error in
            print(error)
        }
        Communicator.shared.send(message)
    }
}
