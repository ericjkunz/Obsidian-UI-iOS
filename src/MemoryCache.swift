//
//  MemoryCache.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public final class MemoryCache<K: AnyObject, T: AnyObject where K: Hashable> {

    // MARK: Public Properties

    /// The cache's identifier
    public let identifier: String

    /// The number of objects the cache is allowed to hold.  This limit is an estimate and is not interpreted strictly.
    public var countLimit: Int {
        get {
            return cache.countLimit
        }
        set {
            cache.countLimit = newValue
        }
    }

    // MARK: Private Properties

    private let cache = Cache<K, T>()

    // MARK: Initialization

    /**
    Instantiates a new MemoryCache

    - parameter identifier: The cache's identifier

    - returns: A newly instantiated MemoryCache

    */
    public init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: Cache Access

    /// Gets or sets the cached object for the passed key
    public subscript(key: K) -> T? {
        get {
            return cache.object(forKey: key)
        }
        set {
            if let v = newValue {
                cache.setObject(v, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }

    /// Empties the cache.
    public func clear() {
        cache.removeAllObjects()
    }

}
