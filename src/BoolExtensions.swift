//
//  BoolExtensions.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/17/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

postfix operator ¡ { }

/// :nodoc:
public postfix func ¡ (inout flag: Bool) -> Bool {
    flag = !flag
    return !flag
}

prefix operator ¡ { }

/// :nodoc:
public prefix func ¡ (inout flag: Bool) -> Bool {
    flag = !flag
    return flag
}

/**
 Prefix and postfix operator ¡ inverts Bool value before and after it has been evaluated.

 Use ⌥ + 1 keys for the character ¡.

 */
public protocol Invertable {
    postfix func ¡ (inout flag: Bool) -> Bool
    prefix func ¡ (inout flag: Bool) -> Bool
}

extension Bool : Invertable { }
