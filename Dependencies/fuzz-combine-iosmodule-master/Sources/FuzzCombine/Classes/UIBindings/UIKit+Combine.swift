//
//  UIKit+Combine.swift
//  FuzzCombine
//
//  Created by Stephen Thomas on 4/1/20.
//  Copyright © 2020 Fuzz Productions. All rights reserved.
//

import Combine
#if !os(macOS) && !os(watchOS)
import UIKit

// MARK: UIControl Publisher

public extension UIButton {
    ///  Provides a publisher that fires when a UIControl.Event.primaryActionTriggered
    ///  is triggered.
    ///
    ///  - returns: A publisher that fires when UIControl.Event.primaryActionTriggered is triggered
    func tapPublisher() -> AnyPublisher<Void, Never> {
        ControlPublisher(control: self, event: .primaryActionTriggered)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

public extension UITextField {
    ///  Provides a publisher that fires when a UIControl.Event.primaryActionTriggered
    ///  is triggered.
    ///
    ///  - returns: A publisher that fires when UIControl.Event.primaryActionTriggered is triggered
    func textPublisher() -> AnyPublisher<String?, Never> {
        ControlPublisher(control: self, event: .valueChanged)
            .map {
                if let textfield = $0 as? UITextField {
                    return textfield.text
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
}

public extension UIControl {
    ///  Provides a publisher that fires when a UIControl.Event.primaryActionTriggered
    ///  is triggered.
    ///
    ///  - returns: A publisher that fires when UIControl.Event.primaryActionTriggered is triggered
    func publisher() -> ControlPublisher {
        ControlPublisher(control: self, event: .primaryActionTriggered)
    }
    
    ///  Provides a publisher that fires when a UIControl.Event
    ///  is triggered.
    ///
    ///  - parameter event: UIControl.Event that the publisher is associated with
    ///
    ///  - returns: A publisher that fires when the provided event is triggered
    func publisherForEvent(event: UIControl.Event) -> ControlPublisher {
        ControlPublisher(control: self, event: event)
    }
}


@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ControlPublisher: Publisher {
    public typealias Output = UIControl
    public typealias Failure = Never
    weak var control: UIControl?
    let event: UIControl.Event
    init(control: UIControl, event: UIControl.Event) {
        self.control = control
        self.event = event
    }
    
    public func receive<S>(subscriber: S)
        where S: Subscriber, S.Input == Output, S.Failure == Failure {
            if let control = control {
                subscriber.receive(subscription:
                    Inner(downstream: subscriber, sender: control, event: event))
            }
    }
    
    class Inner<S: Subscriber>: NSObject, Subscription
    where S.Input == Output, S.Failure == Failure {
        weak var sender: UIControl?
        var downstream: S?
        var event: UIControl.Event?
        init(downstream: S, sender: UIControl, event: UIControl.Event) {
            self.downstream = downstream
            self.sender = sender
            self.event = event
            super.init()
        }
        
        func request(_ demand: Subscribers.Demand) {
            sender?.addTarget(
                self,
                action: #selector(doAction),
                for: event ?? .primaryActionTriggered
            )
        }
        
        func cancel() {
            finish()
        }
        
        deinit {
            self.finish()
        }
        
        private func finish() {
            sender?.removeTarget(
                self,
                action: #selector(doAction),
                for: event ?? .primaryActionTriggered
            )
            sender = nil
            downstream = nil
        }
        
        @objc func doAction(_ sender: UIControl) {
            guard let sender = self.sender else { return }
            _ = downstream?.receive(sender)
        }
    }
}
#endif
