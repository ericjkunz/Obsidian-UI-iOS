//
//  BaseTabBar.swift
//  Alfredo
//
//  Created by Nick Lee on 8/21/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

public class BaseTabBar: UIView {

    /// A weak reference to the parent tab bar controller
    public weak var delegate: TabBarDelegate!

    /// A method called by the parent tab bar controller when the layout should change
    public func layout() {}

    /// A method called by the parent tab bar controller when the receiver should update its UI for a selected tab
    public func selectTab(index: Int) {}

    /// This method must be overridden to return the frame for the tab at the passed index
    public func frameForTab(index: Int) -> CGRect {
        return CGRect.zero
    }

}
