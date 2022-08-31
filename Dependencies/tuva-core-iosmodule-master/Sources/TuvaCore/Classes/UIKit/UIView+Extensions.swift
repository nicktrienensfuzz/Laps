//
// UIView+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation
#if canImport(UIKit) && !os(watchOS)
    import UIKit

    public extension UIView {
        /// Fade in a view with a duration
        ///
        /// Parameter duration: custom animation duration
        func fadeIn(withDuration duration: TimeInterval = 0.30) {
            if isHidden {
                isHidden = false
                alpha = 0.0
            }
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1.0
        })
        }

        /// Fade out a view with a duration
        ///
        /// - Parameter duration: custom animation duration
        func fadeOut(withDuration duration: TimeInterval = 0.30) {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0.0
        })
        }

        /// Fade out a view with a duration
        ///
        /// - Parameter duration: custom animation duration
        func fadeOutAndRemove(withDuration duration: TimeInterval = 1.0) {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0.0
            }, completion: {
                if $0 {
                    self.removeFromSuperview()
                }
         })
        }

        /// Rounded corners for a `UIView` via the layer and masking
        /// - Parameters:
        ///   - corners: Defines which corners should be rounded.
        ///   - radius:  Defines the radius of the round corners as a `CGFloat`.
        func roundCornersWithMask(_ corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }

        /// Add a Shadow path to the view's layer
        /// - Parameters:
        ///   - shadowColor: Color to cast
        ///   - shadowOffset: A size to offset the shadow by compared to the view's bounds
        ///   - shadowOpacity: The opacity of the shadow. Defaults to 0. Specifying a value outside the
        ///                     [0,1] range will give undefined results.
        ///   - shadowRadius: The blur radius used to create the shadow. Defaults to 1
        func addShadow(
            shadowColor: CGColor = UIColor.black.cgColor,
            shadowOffset: CGSize = CGSize(width: 0, height: 1),
            shadowOpacity: Float = 0.4,
            shadowRadius: CGFloat = 1
        ) {
            layer.shadowColor = shadowColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius

            clipsToBounds = false

            let shadowFrame: CGRect = layer.bounds
            let shadowPath: CGPath = UIBezierPath(rect: shadowFrame).cgPath
            layer.shadowPath = shadowPath
        }
    }
#endif
