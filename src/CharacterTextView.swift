//
//  CharacterTextView.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import CoreText

 class CharacterTextView: UITextView, NSLayoutManagerDelegate {

    var oldCharacterTextLayers: [CALayer] = []
    var characterTextLayers: [CALayer] = []

    override var text: String! {
        get {
            return super.text
        }

        set {
            self.attributedText = AttributedString(string: newValue)
        }

    }

    override var attributedText: AttributedString! {
        get {
            return super.attributedText
        }

        set {
            cleanOutOldCharacterTextLayers()
            oldCharacterTextLayers = Array<CALayer>(characterTextLayers)
            let newAttributedText = NSMutableAttributedString(attributedString: newValue)
            newAttributedText.addAttribute(NSForegroundColorAttributeName, value:UIColor.clear(), range: NSRange(location: 0, length: newValue.length))
            super.attributedText = newAttributedText
        }

    }

    override init(frame: CGRect, textContainer: NSTextContainer!) {
        super.init(frame: frame, textContainer: textContainer)
        setupLayoutManager()
    }

    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayoutManager()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayoutManager()
    }

    func setupLayoutManager() {
        layoutManager.delegate = self
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers()
    }

    func calculateTextLayers() {

        let wordRange = NSRange(location: 0, length: attributedText.length)
        let attributedString = self.internalAttributedText()

        var index = 0
        while wordRange.location..<wordRange.length+wordRange.location ~= index {
            let glyphRange = NSRange(location: index, length:  1)
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange:nil)
            let textContainer = layoutManager.textContainer(forGlyphAt: index, effectiveRange: nil)
            var glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer!)
            let location = layoutManager.location(forGlyphAt: index)
            let kerningRange = layoutManager.range(ofNominallySpacedGlyphsContaining: index)

            if kerningRange.length > 1 && kerningRange.location == index {
                let previousLayer = self.characterTextLayers[self.characterTextLayers.endIndex]
                var frame = previousLayer.frame
                frame.size.width += (glyphRect.maxX+location.x)-frame.maxX
                previousLayer.frame = frame
            }

            glyphRect.origin.y += location.y-(glyphRect.height/2)
            let textLayer = CATextLayer(frame: glyphRect, string: (attributedString?.attributedSubstring(from: characterRange))!)

            layer.addSublayer(textLayer)
            characterTextLayers.append(textLayer)

            let stepGlyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange:nil)
            index += stepGlyphRange.length
        }
    }

    func internalAttributedText() -> NSMutableAttributedString! {
        let wordRange = NSRange(location: 0, length: self.attributedText.length)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSForegroundColorAttributeName, value: textColor!.cgColor, range: wordRange)
        attributedText.addAttribute(NSFontAttributeName, value: font!, range: wordRange)
        return attributedText
    }

    func cleanOutOldCharacterTextLayers() {
        //Remove all text layers from the superview
        for textLayer in oldCharacterTextLayers {
            textLayer.removeFromSuperlayer()
        }
        //clean out the text layer
        characterTextLayers.removeAll(keepingCapacity: false)
    }
}
