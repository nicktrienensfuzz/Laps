//
// UIResponder+resign.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation
#if canImport(UIKit) && !os(watchOS)
    import UIKit

    public extension UIViewController {
        // resignFirstResponder on any subview of this viewController
        func resignAnyFirstResponder() {
            view.resignAnyFirstResponder()
        }
    }

    public extension UIView {
        // resignFirstResponder on any subview of this view
        func resignAnyFirstResponder() {
            if isFirstResponder {
                resignFirstResponder()
                return
            }
            subviews.forEach { $0.resignAnyFirstResponder() }
        }
    }
#endif
