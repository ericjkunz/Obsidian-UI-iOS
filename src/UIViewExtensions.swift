//
//  UIViewExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UIView {

    // MARK: Applying Borders

    /**
    Applies a border to the receiver's unerlying CALayer

    - parameter width: The width of the border
    - parameter color: The color of the border

    */
    public func applyBorder(width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    /// Removes the border from the receiver's underlying CALayer
    public func removeBorder() {
        layer.borderColor = UIColor.clear().cgColor
        layer.borderWidth = 0.0
    }

    // MARK: Rounding Corners

    /// Makes the view circular by setting the underlying's CALayer's cornerRadius and masking properties
    public func makeCircular() {
        let w = round((width + height) / 2.0)
        let radius = round(w / 2.0)
        roundCorners(radius)
    }

    /**
    Rounds the corners of the view's underlying CALayer

    - parameter radius: The value to use for the underlying CALayer's cornerRadius property
    - parameter mask: Whether or not the underlying layer should mask to its bounds

    */
    public func roundCorners(radius: CGFloat, mask: Bool = true) {
        layer.cornerRadius = radius
        layer.masksToBounds = mask
    }

    // MARK: Geometry

    /// The x position of the view's frame
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }

    /// The y position of the view's frame
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }

    /// The width of the view's frame
    public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }

    /// The height position of the view's frame
    public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }

    // MARK: Search

    /// Returns a superview (by walking up the chain) of type klass
    public func findSuperview<T: UIView>(klass: UIView.Type) -> T? {
        if let s = superview {
            if s.isKindOfClass(klass) {
                return s as? T
            } else {
                return s.findSuperview(klass)
            }
        }
        return nil
    }

}
