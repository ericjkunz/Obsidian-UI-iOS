//
//  ColorButton.swift
//  Alfredo
//
//  Created by Nick Lee on 9/22/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class ColorButton: UIButton {

    private static let ButtonDimmingColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)

    /// The button's color.  Setting this will adjust the background images for the various control states.
    @IBInspectable public var color: UIColor? {
        didSet {
            if let c = color {
                setBackgroundColor(c, forState: .Normal)
            }
        }
    }

    /**
    Sets the background color for the passed control state

    - parameter color: The color to set
    - parameter state: The state for which the color should be set

    */
    public func setBackgroundColor(color: UIColor, forState state: UIControlState) {

        setBackgroundImage(color.image, forState: state)

        if state == .Normal && backgroundImageForState(.Highlighted) == nil {
            let highlightedColor = blendColor(color, ColorButton.ButtonDimmingColor, -, true).image
            setBackgroundImage(highlightedColor, forState: .Highlighted)
        }

    }

}
