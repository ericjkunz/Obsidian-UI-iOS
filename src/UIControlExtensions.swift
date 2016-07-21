//
//  UIControlExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

private class ControlHandler {

    private let handler: (sender: UIControl) -> ()

    private init(handler: (sender: UIControl) -> ()) {
        self.handler = handler
    }

    private dynamic func call(sender: UIControl) {
        handler(sender: sender)
    }

}


/**
Binds a closure to a UIControl's events

- parameter control: The control to bind to
- parameter events: A bitmask specifying the control events for which closure will be executed
- parameter target: The target that should be passed to the handler.  The target will not be retained.
- parameter handler: A closure that will fire when the events are triggered

*/
public func addHandler<T: UIControl, U: AnyObject>(control: T, events: UIControlEvents, target: U, handler: (target: U) -> ((sender: T) -> ())) {

    let newClosure = { [weak target] (sender: UIControl) -> Void in
        if let t = target, let theSender = sender as? T {
            let h1 = handler(target: t)
            h1(sender: theSender)
        }
    }

    let controlHandler = ControlHandler(handler: newClosure)

    let raw = events.rawValue
    let fakePointer = UnsafePointer<Void>(bitPattern: raw)

    let object: UIControl = control

    objc_setAssociatedObject(object, fakePointer, controlHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    control.addTarget(controlHandler, action: #selector(controlHandler.call(sender:)), for: events)

}
