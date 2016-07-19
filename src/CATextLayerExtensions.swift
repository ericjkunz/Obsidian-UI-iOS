//
//  CATextLayerExtensions.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension CATextLayer {
    convenience init(frame: CGRect, string: AttributedString) {
        self.init()
        self.contentsScale = UIScreen.main().scale
        self.frame = frame
        self.string = string
    }
}
