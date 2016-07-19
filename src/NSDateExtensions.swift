//
//  NSDateExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension NSDate {

    // MARK: Formatting

    /// Returns the receiver represented as a short string (e.g. '30s', '4h', '1d')
    public var timeAgo: String {

        let date = self

        let calendar = Calendar.current
        let unitFlags: Calendar.Unit = [Calendar.Unit.minute, Calendar.Unit.hour, Calendar.Unit.day, Calendar.Unit.weekOfYear, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = now.laterDate(date as Date)
        let components = calendar.components(unitFlags, from: earliest, to: latest, options: [])

        if components.year >= 2 {
            return "\(components.year)y"
        } else if components.year >= 1 {
            return "1y"
        } else if components.month >= 2 {
            return "\(components.month! * 4)w"
        } else if components.month >= 1 {
            return "4w"
        } else if components.weekOfYear >= 2 {
            return "\(components.weekOfYear)w"
        } else if components.weekOfYear >= 1 {
            return "1w"
        } else if components.day >= 2 {
            return "\(components.day)d"
        } else if components.day >= 1 {
            return "1d"
        } else if components.hour >= 2 {
            return "\(components.hour)h"
        } else if components.hour >= 1 {
            return "1h"
        } else if components.minute >= 2 {
            return "\(components.minute)m"
        } else if components.minute >= 1 {
            return "1m"
        } else {
            return "\(components.second)s"
        }
    }
}

/// :nodoc:
extension NSDate: Comparable { }

/// :nodoc:
public func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs as Date) == .orderedSame
}

/// :nodoc:
public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}
