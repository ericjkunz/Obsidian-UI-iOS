//
//  NibView.swift
//  Alfredo
//
//  Created by Nick Lee on 10/9/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

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
        loadNib(named: nibName)
    }

    // MARK: Nib Loading

    private func loadNib(named name: String) {
        guard let loadedView = Bundle.main.loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
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
            NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ]
        constraints.forEach { $0.isActive = true }
    }

    // MARK: Configuration

    /// Called when the content view is loaded
    public func configure() {}

}
