//
//  GradientView.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/19/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

@IBDesignable public class GradientView: UIView {

    /// The top color of the gradient.
    @IBInspectable public var startColor: UIColor = UIColor.whiteColor()

    /// The middle color of the gradient.
    @IBInspectable public var middleColor: UIColor = UIColor(red:0.62, green:0.53, blue:0.89, alpha:1)

    /// The bottom color of the gradient.
    @IBInspectable public var endColor: UIColor = UIColor.blackColor()

    /// Whether or not the middle color is present in the gradient in between the startColor and endColor.
    @IBInspectable public var useMiddleColor: Bool = true

    /// Setting this will cause the startColor, middleColor, endColor, and useMiddleColor to be ignored.
    public var colors: [UIColor]?

    // MARK: Initialization

    convenience init(startColor: UIColor, endColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.startColor = startColor
        self.endColor = endColor
        useMiddleColor = false
    }

    convenience init(startColor: UIColor, middleColor: UIColor, endColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.startColor = startColor
        self.middleColor = middleColor
        self.endColor = endColor
        useMiddleColor = true
    }

    public override func drawRect(rect: CGRect) {

        backgroundColor = UIColor.clearColor()

        let gradient = CAGradientLayer()
        gradient.frame = bounds
        if colors != nil {
            gradient.colors = colors?.map({ $0.CGColor })
        } else {
            gradient.colors = [startColor.CGColor]
            if useMiddleColor { gradient.colors?.append(middleColor.CGColor) }
            gradient.colors?.append(endColor.CGColor)
        }
        layer.addSublayer(gradient)
    }

}
