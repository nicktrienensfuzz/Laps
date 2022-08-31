//
// UIImage+Convenience.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

#if canImport(UIKit) && !os(watchOS)
    import UIKit
    public extension UIImage {
        /// The data of the UIImage in PNG format.
        var asData: Data? {
            pngData()
        }

        /// Add Transparent padding to an image
        /// - Parameter insets: UIEdgeInsets with padding to add
        /// - Returns: UIImage
        func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(
                CGSize(
                    width: size.width + insets.left + insets.right,
                    height: size.height + insets.top + insets.bottom
                ), false, scale
            )
            _ = UIGraphicsGetCurrentContext()
            let origin = CGPoint(x: insets.left, y: insets.top)
            draw(at: origin)
            let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return imageWithInsets
        }

        /// Scale an image to a given width.
        ///
        /// - Parameter width: The width to scale the image to.
        /// - Returns: The scaled image.
        func scaled(to width: CGFloat) -> UIImage {
            defer { UIGraphicsEndImageContext() }

            let scale = width / size.width
            let height = size.height * scale
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            draw(in: bounds)

            return UIGraphicsGetImageFromCurrentImageContext() ?? self
        }

        /// Scale an image to a given size.
        /// - Note: Solution from https://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
        ///
        /// - Parameter size: The size to scale the image to.
        /// - Returns: The scaled image.
        func scaled(to size: CGSize) -> UIImage? {
            // UIGraphicsBeginImageContext(newSize);
            // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
            // Pass 1.0 to force exact pixel size.
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }

        func rounded(radius: CGFloat) -> UIImage {
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
            draw(in: rect)
            return UIGraphicsGetImageFromCurrentImageContext()!
        }

        static func roundedOutline(size: CGSize = CGSize(width: 10, height: 10), radius inRadius: CGFloat? = nil, lineWidth: CGFloat = 4.0, color: UIColor, fillColor: UIColor? = nil) -> UIImage? {
            let radius: CGFloat = inRadius ?? size.height / 2.0

            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)

            guard let context = UIGraphicsGetCurrentContext() else {
                return nil
            }

            let path = UIBezierPath(roundedRect: rect.insetBy(dx: lineWidth, dy: lineWidth), cornerRadius: radius)
            path.lineWidth = lineWidth
            color.setStroke()
            if let fillColor = fillColor {
                fillColor.setFill()
                path.fill()
            }
            path.stroke()
            context.addPath(path.cgPath)

            context.closePath()
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            return image
        }

        /// Convert a UIView into a UIImage.
        ///
        /// - Returns: An image represented the view.
        static func snapshot(_ view: UIView) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)

            defer { UIGraphicsEndImageContext() }

            guard let context = UIGraphicsGetCurrentContext() else {
                debugPrint("No context to render image.")
                return UIImage()
            }

            view.layer.render(in: context)

            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                debugPrint("Failed to render image from current context.")
                return UIImage()
            }

            return image
        }
    }
#endif
