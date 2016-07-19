//
//  UITableViewExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/24/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

extension UITableView {

    // MARK: Nib Registration

    /**
    Registers a cell nib of the passed name, using the name as its reuse identifier

    - parameter name: The name of the .nib file, which will also be used as the cell's reuse identifier

    */
    public func registerCellNib(name: String) {
        let nib = NibCache[name] ?? UINib(nibName: name, bundle: NSBundle.mainBundle())
        NibCache[name] = nib
        registerNib(nib, forCellReuseIdentifier: name)
    }

    /// Adds an empty footer view.  This has the effect of hiding extra cell separators.
    public func addEmptyFooterView() {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 320, height: 1))
        let view = UIView(frame: frame)
        tableFooterView = view
    }

    // MARK: Reloading

    /**
    Reloads the passed sections, with or without animation

    - parameter animated: Whether or not the transition should be animated
    - parameter sections: The sections to reload

    */
    public func refreshSections(animated: Bool = false, _ sections: [Int]) {

        let indexSet = NSMutableIndexSet()

        for index in sections {
            indexSet.add(index)
        }

        let animations = { () -> () in
            let animation: UITableViewRowAnimation = animated ? .Automatic : .None
            self.reloadSections(indexSet, withRowAnimation: animation)
        }

        if animated {
            animations()
        } else {
            UIView.performWithoutAnimation(animations)
        }

    }

}
