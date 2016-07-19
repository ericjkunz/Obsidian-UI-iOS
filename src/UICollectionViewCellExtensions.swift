//
//  UICollectionViewCellExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {

    /// Returns a nil cell - useful when adding in collection view datasource stubs that won't compile unless you return something
    public static var nilCell: UICollectionViewCell! {
        return nil
    }

}
