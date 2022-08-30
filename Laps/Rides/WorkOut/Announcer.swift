//
//  Announcer.swift
//  Laps
//
//  Created by Nicholas Trienens on 8/30/22.
//

import AVFoundation
import DependencyContainer
import Foundation

extension ContainerKeys {
    static let announcer = KeyedDependency("Announcer", type: Announcer.self)
}

extension DependencyContainer {
    static var announcer: Announcer {
        do {
            return try DependencyContainer.resolve(key: ContainerKeys.announcer)
        } catch {
            let announcer = Announcer()
            DependencyContainer.register(announcer, key: ContainerKeys.announcer)
            return announcer
        }
    }
}

class Announcer {
    let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let speech = AVSpeechUtterance(string: text)
        synthesizer.speak(speech)
    }
}
