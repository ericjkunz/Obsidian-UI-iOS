//
//  TimingExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension TimeInterval {

    // MARK: Timing

    /**
    Runs the passed closure after the duration of the receiver (in seconds) has elapsed.

    - parameter closure: The closure to execute after the delay

    */
    public func delay(closure: () -> ()) {
        let delayTime = DispatchTime.now(dispatch_time_t(DispatchTime.now), Int64(self * Double(NSEC_PER_SEC)))
        delayTime.after(when: DispatchQueue.main(), execute: closure)
    }

}

public extension NSNumber {

    // MARK: Timing

    /// Returns the receiver represented as an NSTimeInterval
    public var seconds: TimeInterval {
        return TimeInterval(self)
    }

    /// Returns the receiver (in minutes) represented as an NSTimeInterval
    public var minutes: TimeInterval {
        return seconds * 60.0
    }

    /// Returns the receiver (in hours) represented as an NSTimeInterval
    public var hours: TimeInterval {
        return minutes * 60.0
    }

    /// Returns the receiver (in days) represented as an NSTimeInterval
    public var days: TimeInterval {
        return hours * 24.0
    }

}
