//
//  UIScrollViewExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

public extension UIScrollView {

    /// Resets the receiver's content offset to CGPointZero.  Animatable.
    public func reset(animated: Bool = false) {
        setContentOffset(CGPoint.zero, animated: animated)
    }

    /// Immediately stops any scrolling animations
    public func stopScrolling() {
        let offset = contentOffset
        setContentOffset(offset, animated: false)
    }

}
