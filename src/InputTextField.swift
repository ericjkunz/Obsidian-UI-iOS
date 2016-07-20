//
//  InputTextField.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

/**
 An InputTextFieldValidityDelegate responds to changes in the validity
 of the field's text.
 
 The validityDelegate is only called if the validityChecker
 of the InputTextField is also set.
 
 */
public protocol InputTextFieldValidityDelegate: class {
    /// When the text becomes valid
    func inputDidBecomeValid(field: InputTextField)
    
    /// Called when the text becomes invalid
    func inputDidBecomeInvalid(field: InputTextField)
}

/**
 A text field that can be used for formatting text as it is typed by the user and/or
 can check the validity of its text. Set the inputTextFormatter to format text
 as it is entered. Set the validityChecker to enable notifying the delgate when the
 field's text is valid.
 
 - warning: The 'Cut' button of the text field is broken for this class and the
 selected text will not get copied to the clipboard.
 
 */
public class InputTextField: UITextField, UITextFieldDelegate {
    
    /**
     An InputFormatter will setup the validityChecker and inputFormatter
     of the InputTextField to fit the InputFormattingType of the
     InputFormatter.
     
     */
    private var formatter: InputFormatter? {
        didSet {
            if let inputFormatter = formatter {
                if let formatifier = inputFormatter.textFormatter {
                    inputTextFormatter = formatifier
                }
                
                if let validifier = inputFormatter.validityChecker {
                    validityChecker = validifier
                }
            }
        }
    }
    
    /// This will setup the validityChecker and inputFormatter.
    public var formattingType: InputFormattingType? {
        get {
            return formatter?.formattingType
        }
        set {
            if let type = newValue {
                formatter = InputFormatter(type: type)
            }
        }
    }
    
    private var valid = false
    
    // MARK: Initialization
    
    convenience init(formattingType: InputFormattingType) {
        self.init(frame: CGRect.zero)
        self.formattingType = formattingType
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        delegate = self
    }
    
    /// The validityDelegate responds to changes in the validity of the field's text.
    public var validityDelegate: InputTextFieldValidityDelegate?
    
    // MARK: Validity
    
    /**
     Called to check the validity of the field's text
     
     e.g. To check if a field has any input set the validChecker as follows
     
     validChecker = {(input: String) -> Bool in return input.length > 0}
     
     - parameter input: the text of the field
     - returns: the validity of the input
     
     */
    public var validityChecker: ((input: String) -> Bool)?
    
    /**
     Called to check the validity of the field's text
     
     - parameter checker: function that returns a Bool representing if the
     field is valid or not.
     
     */
    public func setValidChecker(checker: ((input: String) -> Bool)?) {
        validityChecker = checker
    }
    
    /**
     Performs an immediate check of validity. The validityChecker must be set
     in order for this to work.
     
     - returns: Whether the text is valid. Determined by the validityChecker.
     
     */
    public func checkValidity() -> Bool {
        if let checker = validityChecker {
            return checker(input: text ?? "")
        } else {
            return false
        }
    }
    
    // MARK: Formatting
    
    /**
     Called each time the text field's input is modified. Meant for chaning the format
     of the entered text or what new input is allowed.
     
     - parameter input: the characters entered into the field
     - returns: this will be set as the field's text
     
     */
    public var inputTextFormatter: ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int))?
    
    /**
     Called each time the text field's input is modified. Meant for chaning the format
     of the entered text or what new input is allowed.
     
     - parameter formatter: function that returns text that will become the field's text.
     
     */
    public func setInputFormatter(formatter: ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int))?) {
        inputTextFormatter = formatter
    }
    
    /**
     Checks if the field's input is valid.
     
     - returns: false if the field's input is invalid or the validChecker is nil.
     
     */
    public func isValid() -> Bool {
        if let checker = validityChecker, let enteredText = text {
            return checker(input: enteredText)
        }
        return false
    }
    
    // MARK: TextFieldDelegate
    public override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        let cursorPosition = offset(from: beginningOfDocument, to: selectedTextRange!.start)
        let result: (String, Int)
        
        let nsRange = range.nsRange(in: self)
        
        if let formatter = inputTextFormatter {
            result = formatter(text: self.text ?? "", newInput: text, range: nsRange, cursorPosition: cursorPosition)
        } else {
            result = InputFormatter(type: InputFormattingType.None).resultingString(self.text ?? "", newInput: text, range: nsRange, cursorPosition: cursorPosition)
        }
        
        self.text = result.0
        if let newPosition = position(from: beginningOfDocument, offset: result.1) {
            textRange(from: newPosition, to: newPosition)
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
        
        if let checker = validityChecker {
            let validity = checker(input: text ?? "")
            
            if !valid && validity {
                valid = true
                validityDelegate?.inputDidBecomeValid(field: self)
            } else if valid && !validity {
                valid = false
                validityDelegate?.inputDidBecomeInvalid(field: self)
            }
        }
        
        return false
    }
    
    private func selectedRange() -> NSRange? {
        
        guard let start = selectedTextRange?.start, let end = selectedTextRange?.end else {
            return nil
        }
        
        let location = offset(from: beginningOfDocument, to: start)
        let length = offset(from: start, to: end)
        
        return NSMakeRange(location, length)
    }
    
}

extension UITextRange {
    
    func nsRange(in textView: UITextField) -> NSRange {
        
        let location = textView.offset(from: textView.beginningOfDocument, to: start)
        let length = textView.offset(from: start, to: end)
        
        return NSMakeRange(location, length)
        
    }
    
}
