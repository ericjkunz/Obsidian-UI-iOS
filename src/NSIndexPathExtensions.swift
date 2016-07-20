//
//  NSIndexPathExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
Returns an array of NSIndexPaths with their indexes pre-populated from the passed collection

- parameter collection: The collection from which the index paths will be created.
- parameter startIndex: An integer that will be used to pad the returned index paths.  Defaults to 0.
- parameter section: The section to which the index paths should belong.  Defaults to 0.

- returns: An array of NSIndexPaths generated

*/
public func indexPaths<T: Collection>(collection: T, _ startIndex: Int = 0, _ section: Int = 0) -> [NSIndexPath] {
    if let num = collection.count as? Int {
        let range = 0..<num
        let paths = range.map { IndexPath(item: startIndex + $0, section: section) }
        return paths
    } else {
        fatalError("Could not create index paths for collection with index type: \(T.Index.self)")
    }
}
