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
    public func delay(closure: () -> Void) {
        let time = DispatchTime.now() + DispatchTimeInterval.seconds(Int(self))
        DispatchQueue.main.after(when: time, execute: closure)
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
