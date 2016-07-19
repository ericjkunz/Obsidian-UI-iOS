//
//  UIAlertControllerExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/22/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UIAlertController {

    /**
    Creates and returns a view controller for displaying the passed error message to the user.

    - parameter errorString: Descriptive text that provides additional details about the error.

    - returns: An initialized alert controller object.

    */
    public convenience init(errorString: String) {
        self.init(title: L("Error"), message: errorString, preferredStyle: .alert)
        let action = UIAlertAction(title: L("OK"), style: .cancel, handler: nil)
        addAction(action)
    }

}
