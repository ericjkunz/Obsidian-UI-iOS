//
//  NibView.swift
//  Alfredo
//
//  Created by Nick Lee on 10/9/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public class NibView: UIView {

    // MARK: Properties

    // The view that was loaded in
    public private(set) var contentView: UIView!

    // The name of the nib that should be loaded
    public var nibName: String {
        fatalError("must override nibName var in all NibView subclasses")
    }

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        loadNib(nibName)
    }

    // MARK: Nib Loading

    private func loadNib(name: String) {
        guard let loadedView = Bundle.mainBundle().loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
            fatalError("Failed to load nib named: \(name)")
        }
        loadedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadedView)
        contentView = loadedView
        constrain()
        configure()
    }

    private func constrain() {
        let constraints = [
            NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0)
        ]
        constraints.forEach { $0.active = true }
    }

    // MARK: Configuration

    /// Called when the content view is loaded
    public func configure() {}

}
