//
// UIColor+Convenience.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.
#if canImport(UIKit)

    import UIKit

    public extension UIColor {
        convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
            self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
        }

        convenience init(hex: UInt64, alpha: CGFloat = 1) {
            let red = CGFloat((hex & 0xFF0000) >> 16) / 0xFF
            let green = CGFloat((hex & 0x00FF00) >> 8) / 0xFF
            let blue = CGFloat((hex & 0x0000FF) >> 0) / 0xFF
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }

        convenience init(hex: String, alpha _: CGFloat = 1) {
            let scanner: Scanner
            if hex.first == .some("#") {
                scanner = Scanner(string: hex.removing(first: 1))
            } else {
                scanner = Scanner(string: hex)
            }
            var rgbValue: UInt64 = 0
            scanner.scanHexInt64(&rgbValue)

            self.init(hex: rgbValue)
        }

        func pressed() -> UIColor {
            var r = CGFloat(); var g = CGFloat(); var b = CGFloat(); var a = CGFloat()
            getRed(&r, green: &g, blue: &b, alpha: &a)
            return UIColor(red: r, green: g, blue: b, alpha: max(0.3, a - 0.3))
        }

        /**
         Returns the color representation as hexadecimal string.

         - returns: A string similar to this pattern "#f4003b".
         */
        final func toHexString() -> String {
            String(format: "#%06x", toHex())
        }

        /**
         Returns the color representation as an integer.

         - returns: A UInt32 that represents the hexa-decimal color.
         */
        final func toHex() -> UInt32 {
            func roundToHex(_ x: CGFloat) -> UInt32 {
                guard x > 0 else { return 0 }
                let rounded: CGFloat = round(x * 255)

                return UInt32(rounded)
            }

            let rgba = toRGBAComponents()
            let colorToInt = roundToHex(rgba.r) << 16 | roundToHex(rgba.g) << 8 | roundToHex(rgba.b)

            return colorToInt
        }

        // MARK: - Getting the RGBA Components

        /**
         Returns the RGBA (red, green, blue, alpha) components.

         - returns: The RGBA components as a tuple (r, g, b, a).
         */
        // swiftlint:disable large_tuple
        final func toRGBAComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            getRed(&r, green: &g, blue: &b, alpha: &a)
            return (r, g, b, a)
        }

        func mixed(withColor color: UIColor, weight: CGFloat) -> UIColor {
            let c1 = toRGBAComponents()
            let c2 = color.toRGBAComponents()

            let red = c1.r + weight * (c2.r - c1.r)
            let green = c1.g + weight * (c2.g - c1.g)
            let blue = c1.b + weight * (c2.b - c1.b)
            let alpha = c1.a + weight * (c2.a - c1.a)

            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
#endif
