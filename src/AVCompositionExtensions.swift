//
//  AVMutableCompositionExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/11/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import AVFoundation

public extension AVMutableComposition {

    /**
    Creates a composition that loops the passed asset a variable number of times

    - parameter asset: The asset to repeatedly insert into the composition
    - parameter loops: The number of times the asset's playback should loop

    - returns: An initialized AVMutableComposition object

    */
    public convenience init(asset: AVAsset, loops: Int = 1) {

        self.init()

        let editRange = CMTimeRange(start: kCMTimeZero, duration: asset.duration)

        for _ in 0..<loops {
            do {
                try insertTimeRange(editRange, of: asset, at: duration)
            } catch _ {
            }
        }

    }

}
