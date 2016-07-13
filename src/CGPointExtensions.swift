//
//  CGPointExtensions.swift
//  PropertyAnimator
//
//  Created by Eric Kunz on 7/8/16.
//  Copyright © 2016 Tendigi. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    func distance(to point: CGPoint) -> Double {
        let xDist = point.x - x
        let yDist = point.y - y
        return sqrt(Double(xDist * xDist) + Double(yDist * yDist))
    }
    
}
