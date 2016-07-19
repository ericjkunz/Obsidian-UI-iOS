//
//  ActivityIndicatorView.swift
//  Alfredo
//
//  Created by Nick Lee on 10/2/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

internal final class ActivityIndicatorView: UIView {

    // MARK: Types

    internal struct Config {

        internal let backgroundColor: UIColor
        internal let images: [UIImage]
        internal let duration: TimeInterval
        internal let spaceAboveCenter: CGFloat

        internal init(backgroundColor: UIColor, images: [UIImage], duration: TimeInterval, spaceAboveCenter: CGFloat) {
            self.backgroundColor = backgroundColor
            self.images = images
            self.duration = duration
            self.spaceAboveCenter = spaceAboveCenter
        }

    }

    // MARK: Private Properties

    private let imageView = UIImageView()

    // MARK: Initialization

    internal init(frame: CGRect, config: Config) {
        super.init(frame: frame)

        backgroundColor = config.backgroundColor

        imageView.animationImages = config.images
        imageView.animationDuration = config.duration

        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        var constraints = [
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        ]

        if config.spaceAboveCenter != 0.0 {
            constraints.append(
                NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -config.spaceAboveCenter)
            )
        } else {
            constraints.append(
                NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            )
        }

        constraints.forEach { $0.isActive = true }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Control

    internal func startAnimating() {
        imageView.startAnimating()
    }

    internal func stopAnimating() {
        imageView.stopAnimating()
    }

}
