//
//  UIColorExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 9/21/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {

    /// Returns a 1x1pt image filled with the receiver's color
    public var image: UIImage? {
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}

/**
Blends two UIColors

- parameter color1: The first color to blend
- parameter color2: The second color to blend
- parameter mode: The function to use when blending the channels
- parameter premultiplyAlpha: Whether or not each color's alpha channel should be premultiplied across the RGB channels prior to the blending

- returns: The UIColor resulting from the blend operation

*/
public func blendColor(_ color1: UIColor, _ color2: UIColor, _ mode: ((CGFloat, CGFloat) -> CGFloat), _ premultiplyAlpha: Bool = false) -> UIColor {

    func transform(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return min(1.0, max(0.0, mode(a, b)))
    }

    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    if premultiplyAlpha {

        r1 *= a1
        g1 *= a1
        b1 *= a1

        r2 *= a2
        g2 *= a2
        b2 *= a2

    }

    let newColor = UIColor(red: transform(r1, r2), green: transform(g1, g2), blue: transform(b1, b2), alpha: premultiplyAlpha ? 1.0 : transform(a1, a2))

    return newColor
}

/// :nodoc:
/// Adds the RGBA channels of color1 and color2
public func + (color1: UIColor, color2: UIColor) -> UIColor {
    return blendColor(color1, color2, +)
}

/// :nodoc:
/// Subtracts the RGBA channels of color2 from color1
public func - (color1: UIColor, color2: UIColor) -> UIColor {
    return blendColor(color1, color2, -)
}

/// :nodoc:
/// Multiplies the RGBA channels of color1 and color2
public func * (color1: UIColor, color2: UIColor) -> UIColor {
    return blendColor(color1, color2, *)
}
