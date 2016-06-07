//
//  ArrayExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/20/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension Array {

    /**
     Breaks the array into chunks of the passed size

     - parameter splitSize: The size of each array chunk

     - returns: Chunks of the receiver

     */
    public func chunk(splitSize: Index) -> [[Element]] {
        if count <= splitSize {
            return [self]
        } else {
            return [Array(self[0..<splitSize])] + Array(self[splitSize..<self.count]).chunk(splitSize)
        }
    }

    /// Returns a random index in the Array.
    public func randomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(count)))
    }

    /// Returns a random element of the array.
    public func randomElement() -> Element {
        return self[randomIndex()]
    }

    /**
     Returns the number of elements which meet the condition

     - parameter test: Function to call for each element

     - returns: the number of elements meeting the condition

     */
    func countWhere (test: (Element) -> Bool) -> Int {

        var result = 0

        for item in self {
            if test(item) {
                result += 1
            }
        }

        return result
    }
}

/**
 Creates a dictionary composed of keys generated from the results of
 running each element of self through groupingFunction. The corresponding
 value of each key is an array of the elements responsible for generating the key.

 - parameter groupingFunction:

 - returns: Grouped dictionary

 */
public func group<T, U>(array: Array<T>, group: (Array<T>.Element) -> U) -> [U: Array<T>] {

    var result = [U: Array<T>]()

    for item in array {

        let groupKey = group(item)

        if result[groupKey] != nil {
            result[groupKey]! += [item]
        } else {
            result[groupKey] = [item]
        }

    }

    return result
}

/**
 Returns a filtered version of the receiver with nil values excluded

 - parameter array: The array to filter

 - returns: a filtered version of the receiver with nil values excluded

 */
public func filterNils<T>(array: [T?]) -> [T] {
    return array.filter({ $0 != nil }).map({ $0! })
}
