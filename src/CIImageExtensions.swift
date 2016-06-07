//
//  CIImageExtensions.swift
//  Obsidian UI Test
//
//  Created by Eric Kunz on 6/7/16.
//  Copyright © 2016 Tendigi. All rights reserved.
//

import Foundation

extension CIImage {
    
    func locationOfFaces() -> [CGRect]? {
        let detector = CIDetector(ofType: CIDetectorTypeFace, context:nil, options:nil)
        let features = detector.featuresInImage(self)
        guard features.count > 0 else {
            // No features found
            return nil
        }
        
        return features.map{ $0.bounds }
    }
    
}