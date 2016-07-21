//
//  BasicTabBar.swift
//  Alfredo
//
//  Created by Nick Lee on 8/21/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

// I'm not very proud of this class...

import UIKit

public final class BasicTabBar: BaseTabBar {
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = backgroundColor ?? UIColor.white()
    }
    
    /// The accent color, used for the selected tab text and indicator
    public override var tintColor: UIColor! {
        didSet {
            layoutButtons()
            setNeedsDisplay()
        }
    }
    
    /// The text color used for non-selected tabs
    public var textColor: UIColor = UIColor(red:0.14, green:0.14, blue:0.15, alpha:1) {
        didSet {
            layoutButtons()
            setNeedsDisplay()
        }
    }
    
    /// The height of the selected tab indicator
    public var indicatorHeight: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The font used for the tab text
    public var tabFont = UIFont.systemFont(ofSize: UIFont.systemFontSize()) {
        didSet {
            layoutButtons()
        }
    }
    
    // MARK: Layout
    
    private func layoutButtons() {
        
        guard delegate != nil else {
            return
        }
        
        subviews.forEach { $0.removeFromSuperview() }
        
        let tabNames = delegate.tabNames
        
        let buttons = tabNames.map { (title) -> UIButton in
            let b = UIButton(type: .custom)
            b.setTitle(title, for: .normal)
            b.addTarget(self, action: #selector(BasicTabBar.selectTabButton), for: .touchUpInside)
            b.titleLabel?.font = self.tabFont
            b.setTitleColor(self.textColor, for: .normal)
            b.setTitleColor(self.tintColor, for: .selected)
            b.setTitleColor(self.tintColor, for: .highlighted)
            return b
        }
        
        let buttonSize = ceil(width / CGFloat(tabNames.count))
        
        var x: CGFloat = 0
        
        for (i, b) in buttons.enumerated() {
            b.x = x
            b.y = 0
            b.width = buttonSize
            b.height = height
            b.tag = i
            x += buttonSize
        }
        
        buttons.forEach { self.addSubview($0) }
        
        selectTab(delegate.selectedTabIndex)
        
    }
    
    // MARK: BaseTabBar overrides
    
    /// :nodoc:
    public override func layout() {
        super.layout()
        layoutButtons()
    }
    
    /// :nodoc:
    public override func selectTab(_ index: Int) {
        
        if var buttons = subviews as? [UIButton] {
            buttons.sort(isOrderedBefore: { $0.x < $1.x })
            for (i, b) in buttons.enumerated() {
                b.isSelected = (i == index)
            }
        }
        setNeedsDisplay()
    }
    
    public override func frameForTab(_ index: Int) -> CGRect {
        if var buttons = subviews as? [UIButton] {
            buttons.sort(isOrderedBefore: { $0.x < $1.x })
            for (i, b) in buttons.enumerated() {
                if i == index {
                    return b.frame
                }
            }
        }
        return super.frameForTab(index)
    }
    
    // MARK: Actions
    private dynamic func selectTabButton(button: UIButton) {
        delegate.selectTab(button.tag)
    }
    
    // MARK: UIView Overrides
    
    /// :nodoc:
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let buttonWidth = rect.width / CGFloat(delegate.tabNames.count)
        tintColor.setFill()
        let fillRect = CGRect(x: buttonWidth * CGFloat(delegate.selectedTabIndex), y: rect.height - indicatorHeight, width: buttonWidth, height: indicatorHeight)
        UIRectFill(fillRect)
    }
    
    /// :nodoc:
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
    
}
