//
//  DictionaryExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

extension Dictionary {

    private init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }

    /**
    Maps elements to new elements.

    :param transform A closure that returns transformed versions of the dictionary's key-value pairs

    :return A mapped dictionary

    */
    func map<OutKey: Hashable, OutValue>(transform: (Element) -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(self.map(transform))
    }

    /**
    Filters a dictinoary by its elements

    :param includeElement A closure that acts as the inclusion predicate for a specific element

    :return A filtered dictionary

    */
    func filter(includeElement: (Element) -> Bool) -> [Key: Value] {
        return Dictionary(self.filter(includeElement))
    }

}
