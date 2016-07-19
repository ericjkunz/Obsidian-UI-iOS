//
//  ScrollLoader.swift
//  Alfredo
//
//  Created by Nick Lee on 8/28/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public protocol ScrollLoaderDelegate: class {

    /// Loads data at the requested page
    func load(loader: ScrollLoader, page: Int)

    /// Returns the number of objects currently loaded
    func count(loader: ScrollLoader) -> Int

}

public class ScrollLoader {

    // MARK: Types

    /// An enum representing the direction of scrolling
    public enum Direction {
        case Vertical
        case Horizontal
    }

    // MARK: Public Properties

    /// The loader's delegate
    public weak var delegate: ScrollLoaderDelegate!

    /// The current page of results
    public private(set) var page: Int = 0

    /// The scroll direction
    public let direction: Direction

    /// Whether or not the loader is loading
    public private(set) var loading: Bool = false

    /// Whether or not the loader has reached the end of its results
    public private(set) var ended: Bool = false

    // MARK: Private Properties

    private var previousCount: Int = 0

    // MARK: Initialization

    /**
    Instantiates a new ScrollLoader

    - parameter direction: The direction in which the associated scroll view scrolls

    - returns: a new ScrollLoader object

    */
    public init(direction: Direction) {
        self.direction = direction
    }

    // MARK: Loading Management

    private func startLoading() {
        loading = true
        previousCount = delegate.count(loader: self)
        delegate?.load(loader: self, page: page)
    }

    /**
    A method to be called when loading completes

    - parameter success: Whether or not the request was successful

    */
    public func completeLoading(success: Bool) {

        loading = false

        if success && previousCount == delegate.count(loader: self) {
            ended = true
        } else if success {
            page += 1
        }

    }

    // MARK: Control

    /// Start the ScrollLoader.  Typically you'd call this in your view controller's -viewDidLoad method
    public func start() {
        startLoading()
    }

    // MARK: Scroll Tracking

    /**
    Tracks a scroll view and fires delegate methods as necessary

    - parameter scrollView: The UIScrollView to track

    */
    public func trackScroll(scrollView: UIScrollView) {

        var distance = CGFloat.greatestFiniteMagnitude
        var dimension = CGFloat.greatestFiniteMagnitude

        switch direction {
        case .Vertical:
            distance = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.height)
            dimension = scrollView.height
        case .Horizontal:
            distance = scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.width)
            dimension = scrollView.width
        }

        let threshold = dimension / 2

        if !loading && !ended && distance.floatingPointClass == .positiveNormal && distance < threshold {
            startLoading()
        }

    }

}
