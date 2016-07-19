//
//  ALFNavigationTitleTaglineView.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/14/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

///A view meant for UINavigationItem's titleView. Has two labels - one larger(title) and one below and smaller(tagline).
public class TitleTaglineView: UIView {

    /// Height of the top, title label.
    public var titleHeight: CGFloat = 26

    /// What the top, title label reads.
    public var title = "Title"

    /// What the bottom, tagline label reads.
    public var tagline = "Tagline"

    /// Font of the title label.
    public var titleFont = UIFont.preferredFont(forTextStyle: UIFontTextStyleHeadline)

    /// Font of the tagline label.
    public var taglineFont = UIFont.preferredFont(forTextStyle: UIFontTextStyleSubheadline)

    /**
    Initializes an ALFTitleTaglineView

    - parameter title: What the top label reads.
    - parameter tagline: What the bottom label reads.
    - parameter frame: The location of the view.

    */
    public init(title: String, tagline: String, frame: CGRect) {
        self.title = title
        self.tagline = tagline
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: titleHeight))
        titleLabel.textColor = UIColor.white()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = titleFont
        titleLabel.text = title
        addSubview(titleLabel)

        let taglineLabel = UILabel(frame: CGRect(x: 0, y: titleHeight, width: frame.size.width, height: frame.size.height - titleHeight))
        taglineLabel.textColor = UIColor.white()
        taglineLabel.textAlignment = NSTextAlignment.center
        taglineLabel.font = taglineFont
        taglineLabel.text = tagline
        addSubview(taglineLabel)
    }
}
