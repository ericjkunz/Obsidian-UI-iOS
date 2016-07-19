//
//  Globals.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

// MARK: Localization

/**
 Returns a localized string from the main bundle's default localized strings table
 
 - parameter key: The key to look up
 
 - returns: The localized string if it exists, otherwise returns the key passed in.
 
 */
public func L(_ key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: Bundle.main, comment: "")
}

/// Returns a random UIColor
public func randomColor() -> UIColor {
    
    var 💩: CGFloat {
        let divisor: UInt32 = 50
        let dividend = CGFloat(arc4random_uniform(divisor))
        return dividend / CGFloat(divisor)
    }
    
    return UIColor(red: 💩, green: 💩, blue: 💩, alpha: 1.0)
    
}

/// The main queue (equivalent to calling `dispatch_get_main_queue()`)
public let MainQueue: DispatchQueue = {
    return DispatchQueue.main
}()


/// The background queue (equivalent to calling `dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)`)
public let BackgroundQueue: DispatchQueue = {
    return GlobalQueue()
}()

/**
 Returns the global queue with the passed identifier
 
 - parameter identifier: The quality of service you want to give to tasks executed using this queue. You may also specify one of the dispatch queue priority values.
 
 - returns: The requested global concurrent queue.
 
 */
public func GlobalQueue(identifier: DispatchQueue.GlobalAttributes = DispatchQueue.GlobalAttributes.qosDefault) -> DispatchQueue {
    return DispatchQueue.global(attributes: identifier)
}

internal struct Constants {
    static let ImageCacheName = "com.tendigi.alfredo.imageCache"
    static let NibCacheName = "com.tendigi.alfredo.nibCache"
    static let DefaultIndicatorName = "com.tendigi.alfredo.defaultIndicator"
}

internal let NibCache = MemoryCache<NSString, UINib>(identifier: Constants.NibCacheName)

/// Return the index of an element matching the passed predicate in the given sequence, or nil if the element is not found in the sequence.
public func search<C: Collection>(source: C, predicate: (C.Iterator.Element) -> Bool) -> C.Index? {
    
    var i = source.startIndex
    
    while i != source.endIndex {
        if predicate(source[i]) {
            return i
        }
        i = source.index(after: i)
    }
    
    return nil
}

/// Prints a collection in a human-readable format
public func print<A: Collection>(collection: A ) {
    let sz = collection.count
    if sz == 0 {
        Swift.print("[]")
    } else {
        Swift.print("[")
        for x in collection {
            let str = "\t\(x)"
            Swift.print(str)
        }
        Swift.print("]")
    }
}

/// Returns a random Double between min and max
public func rand(min: Double, max: Double) -> Double {
    let delta = max - min
    let resolution: UInt32 = 1024
    let rand = arc4random_uniform(resolution)
    return floor(min + ( (Double(rand) / Double(resolution)) * delta ))
}

/// Returns a random Float between min and max
public func rand(min: Float, max: Float) -> Float {
    return Float(rand(min: min, max: max))
}

/// Returns a random CGFloat between min and max
public func rand(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(rand(min:min, max: max))
}

/// Returns a closure that calls the passed function once it has been left alone for the passed delay (seconds)
func debounce( delay: Double, queue: DispatchQueue = .main, action: VoidFunction ) -> VoidFunction {
    let delayInMilliseconds = DispatchTimeInterval.milliseconds(Int(delay * 1000.0))
    return debounce(delay: delayInMilliseconds, queue: queue, action: action)
}

/// Returns a closure that calls the passed function once it has been left alone for the passed delay
func debounce( delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: VoidFunction ) -> VoidFunction {
    
    var lastFireTime = DispatchTime.now()
    
    return {
        lastFireTime = .now()
        queue.after(when: .now() + delay) {
            let now = DispatchTime.now()
            let when = lastFireTime + delay
            if now.rawValue >= when.rawValue {
                action()
            }
        }
    }
}
