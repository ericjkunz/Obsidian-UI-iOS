//
//  Mutex.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public struct MutexPool {

    private let semaphore: DispatchSemaphore

    // MARK: Initialization

    /**
    Creates a new MutexPool with an initial pool size.

    - parameter poolSize: The starting value of the MutexPool

    - returns: A newly instantiated MutexPool

    */
    public init(poolSize: Int = 1) {
        semaphore = DispatchSemaphore(value: poolSize)
    }

    /**
    Waits for a resource in the pool to become available

    - parameter timeout: When to timeout (see dispatch_time). The constants DISPATCH_TIME_NOW and DISPATCH_TIME_FOREVER are available as a convenience.

    */
    public func wait(timeout: DispatchTime = DispatchTime.distantFuture) {
        _ = semaphore.wait(timeout: timeout)
    }

    /// Frees a used resource in the pool
    public func signal() {
        semaphore.signal()
    }

    /**
    Waits for resources to become available, performs the passed closure, and signals after it returns.

    - parameter closure: The closure to execute when a resource becomes available

    */
    public func perform(closure: () -> ()) {
        wait()
        closure()
        signal()
    }

}
