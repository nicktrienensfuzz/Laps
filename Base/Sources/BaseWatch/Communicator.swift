//
//  File.swift
//
//
//  Created by Nicholas Trienens on 8/25/22.
//

import Communicator
import DependencyContainer
import Foundation

public extension ContainerKeys {
    static var commsKey = KeyedDependency("comms", type: Comms.self)
}

public class Comms {
    public enum Action: String {
        case startActivity
        case stopActivity
    }

    public func sendMessage(_ action: Action) {
        let message = InteractiveImmediateMessage(identifier: "actions", content: ["action": action.rawValue]) { error in
            print(error)
        }
        Communicator.shared.send(message)
    }
}
