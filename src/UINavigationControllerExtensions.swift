//
//  UINavigationControllerExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 9/11/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UINavigationController {

    /**
    Replaces the passed view controller with the passed replacement

    - parameter find: The controller to search for
    - parameter replace: The controller to replace
    - parameter animated: If YES, animate the pushing or popping of the top view controller. If NO, replace the view controller without any animations.

    */
    public func replace(find: UIViewController, replace: UIViewController, animated: Bool) {
        var vcs = self.viewControllers
        if let index = search(source: vcs, predicate: { $0 === find }) {
            vcs[index] = replace
        }
        setViewControllers(vcs, animated: animated)
    }

}
