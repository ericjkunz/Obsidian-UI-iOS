//
//  CIImageExtensions.swift
//  Obsidian UI Test
//
//  Created by Eric Kunz on 6/7/16.
//  Copyright © 2016 Tendigi. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage

extension CIImage {

    func faceRects() -> [CGRect] {
        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context:nil, options:nil) else {
            return [CGRect]()
        }
        
        let features = detector.features(in: self)
        guard features.count > 0 else {
            // No features found
            return [CGRect]()
        }
        
        return features.map{ $0.bounds }
    }
    
}
