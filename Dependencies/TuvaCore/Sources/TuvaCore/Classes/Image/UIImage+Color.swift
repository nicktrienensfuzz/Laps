//
// UIImage+Color.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

#if canImport(UIKit) && !os(watchOS)
    import UIKit
    public extension UIImage {
        func resize(targetSize: CGSize = CGSize(width: 900, height: 900)) -> UIImage {
            let image = self
            let size = image.size

            let widthRatio = targetSize.width / image.size.width
            let heightRatio = targetSize.height / image.size.height

            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }

            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? self
        }

        /// Return an image swatch of a color.
        ///
        /// - Parameter color: The color to represent as an image.
        /// - Returns: The color as an image.
        static func from(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
            autoreleasepool { () -> UIImage in
                let pixel = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                pixel.backgroundColor = color

                return .snapshot(pixel)
            }
        }

        func roundedOutline(size: CGSize = CGSize(width: 10, height: 10), radius inRadius: CGFloat? = nil, lineWidth: CGFloat = 2.0, color: UIColor, fillColor: UIColor? = nil) -> UIImage? {
            autoreleasepool { () -> UIImage? in
                let radius: CGFloat = inRadius ?? size.height / 2.0

                let rect = CGRect(origin: .zero, size: size)
                UIGraphicsBeginImageContextWithOptions(size, false, 2)

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
        }

        /// Replace the mask of an image with the specified. If the image cannot be derived, the original is returned.
        ///
        /// Derived with little change from https://coffeeshopped.com/2010/09/iphone-how-to-dynamically-color-a-uiimage
        ///
        /// - Parameter color: The color to replace the mask with.
        func with(color: UIColor) -> UIImage {
            autoreleasepool { () -> UIImage in
                UIGraphicsBeginImageContextWithOptions(size, false, scale)
                defer { UIGraphicsEndImageContext() }

                guard let context = UIGraphicsGetCurrentContext(),
                    let cgImage = self.cgImage else {
                    return self
                }

                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1.0, y: -1.0)

                color.setFill()
                context.setBlendMode(.normal)
                let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                context.draw(cgImage, in: bounds)
                context.clip(to: bounds, mask: cgImage)
                context.addRect(bounds)
                context.drawPath(using: .fill)

                guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
                return image
            }
        }
    }
#endif
