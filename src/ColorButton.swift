//
//  ColorButton.swift
//  Alfredo
//
//  Created by Nick Lee on 9/22/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

/**
 By setting the color property of a ColorButton you also get a darker version
 of that color for the highlighted state of the button.
 
 */
@IBDesignable public class ColorButton: UIButton {
    
    private static let ButtonDimmingColor = UIColor.white().withAlphaComponent(0.1)
    
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
        
        setBackgroundImage(color.image, for: state)
        
        if state == .normal && backgroundImage(for: .highlighted) == nil {
            let highlightedColor = blendColor(color, ColorButton.ButtonDimmingColor, -, true).image
            setBackgroundImage(highlightedColor, forState: .Highlighted)
        }
        
    }
    
}
