//
//  StringExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/26/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension String {

    /// Generates an NSURL from the receiver, if possible.
    public var URL: NSURL? {
        return NSURL(string: self)
    }

    /// The number of individual, composed character sequences
    public var length: Int { return characters.count }

    // Returns the character at index i
    public subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    /// Removes the end character from the String
    public mutating func removeLastCharacter() { removeCharactersFromEnd(1) }

    /**
    Removes a number of characters from the end of the String.

    - parameter removeThisMany: The number of characters to remove from the end of the String.

    */
    public mutating func removeCharactersFromEnd(_ removeThisMany: Int) {
        self = substring(to: index(endIndex, offsetBy: -removeThisMany))
    }

    /// Removes the first character from the String.
    public mutating func removeFirstCharacter() { removeCharactersFromStart(1) }

    /**
    Removes a number of characters from the start of the String.

    - Parameter removeThisMany: The number of characters to remove from the start of the String.

    */
    public mutating func removeCharactersFromStart(_ removeThisMany: Int) {
        self = substring(from: index(startIndex, offsetBy: removeThisMany, limitedBy: endIndex)!)
    }
}
