//
//  UITableViewCellExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/27/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UITableViewCell {

    /// Returns a nil cell - useful when adding in table view datasource stubs that won't compile unless you return something
    public static var nilCell: UITableViewCell! {
        return nil
    }

}
