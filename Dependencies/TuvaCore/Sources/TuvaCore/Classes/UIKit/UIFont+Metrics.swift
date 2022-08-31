//
//  UIFont+Metrics.swift
//  Nimble
//
//  Created by Nick Trienens on 7/7/20.
//

import Foundation

#if canImport(UIKit)
    import UIKit

    public extension UIFont {
        /// Converts the receiver to a scalable font
        /// - Parameter maximumPointSize: an optional maximum font size to allow
        /// - Returns: Returns a Scalable version of the current font, if available otherwise self
        func scaledFont(maximumPointSize: CGFloat? = nil) -> UIFont {
            if #available(iOS 11.0, *) {
                if let maximumPointSize = maximumPointSize {
                    return UIFontMetrics.default.scaledFont(for: self, maximumPointSize: maximumPointSize)
                } else {
                    return UIFontMetrics.default.scaledFont(for: self)
                }
            }
            return self
        }
    }

#endif
