//
//  InputFormatter.swift
//  Alfredo
//
//  Created by Eric Kunz on 9/15/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/// Formatting style options
public enum InputFormattingType {
    /// Use with custom validation
    case None
    /// e.g. $00.00. Valid with any value greater than $0.
    case DollarAmount
    /// e.g. 00/00/0000
    case Date
    /// e.g. 00/00
    case CreditCardExpirationDate
    /// e.g. 0000 0000 0000 0000 - VISA/MASTERCARD
    case CreditCardSixteenDigits
    /// e.g. 0000 000000 00000 - AMEX
    case CreditCardFifteenDigits
    /// e.g. 000
    case CreditCardCVVThreeDigits
    /// e.g. 0000
    case CreditCardCVVFourDigits
    /// Allows any characters. Limits the character count and valid only when at limit
    case LimitNumberOfCharacters(Int)
    /// Limits the count of numbers entered. Valid only at set limit
    case LimitNumberOfDigits(Int)
    /// Only allows characters from the NSCharacterSet to be entered
    case LimitToCharacterSet(NSCharacterSet)
    /// Any input with more than zero characters
    case AnyLength
}

class InputFormatter {

    typealias inputTextFormatter = ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int))?
    typealias validChecker = ((input: String) -> Bool)?
    var formattingType = InputFormattingType.None

    private lazy var numberFormatter = NSNumberFormatter()
    private lazy var currencyFormatter = NSNumberFormatter()
    private lazy var dateFormatter = NSDateFormatter()

    init(type: InputFormattingType) {
        formattingType = type
    }

    var textFormatter: inputTextFormatter {
        switch self.formattingType {
        case .None:
            return nil
        case .DollarAmount:
            return formatCurrency
        case .Date:
            return formatDate
        case .CreditCardExpirationDate:
            return formatCreditCardExpirationDate
        case .CreditCardSixteenDigits:
            return formatCreditCardSixteenDigits
        case .CreditCardFifteenDigits:
            return formatCreditCardFifteenDigits
        case .CreditCardCVVThreeDigits:
            return formatCreditCardCVVThreeDigits
        case .CreditCardCVVFourDigits:
            return formatCreditCardCVVFourDigits
        case .LimitNumberOfCharacters(let length):
            return limitToLength(length)
        case .LimitNumberOfDigits(let length):
            return limitToDigitsWithLength(length)
        case .LimitToCharacterSet(let characterSet):
            return limitToCharacterSet(characterSet)
        case .AnyLength:
            return nil
        }
    }

    var validityChecker: validChecker {
        switch self.formattingType {
        case .None:
            return nil
        case .DollarAmount:
            return validateCurrency
        case .Date:
            return isLength(10)
        case .CreditCardExpirationDate:
            return isLength(5)
        case .CreditCardSixteenDigits:
            return isLength(19)
        case .CreditCardFifteenDigits:
            return isLength(17)
        case .CreditCardCVVThreeDigits:
            return isLength(3)
        case .CreditCardCVVFourDigits:
            return isLength(4)
        case .LimitNumberOfCharacters(let numberOfCharacters):
            return isLength(numberOfCharacters)
        case .LimitNumberOfDigits(let length):
            return isLength(length)
        case .LimitToCharacterSet:
            return nil
        case .AnyLength:
            return hasLength
        }
    }

    // MARK:- Formatters

    private func formatCurrency(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 21 else {
                return (text, cursorPosition)
            }
        }

        let (noSpecialsString, newCursorPosition) = removeNonDigits(text, cursorPosition: cursorPosition)
        let removedCharsCorrectedRange = NSRange(location: range.location + (newCursorPosition - cursorPosition), length: range.length)
        let (newText, _) = resultingString(noSpecialsString, newInput: newInput, range: removedCharsCorrectedRange, cursorPosition: newCursorPosition)

        currencyFormatter.numberStyle = .DecimalStyle
        let number = currencyFormatter.numberFromString(newText) ?? 0
        let newValue = NSNumber(double: number.doubleValue / 100.0)
        currencyFormatter.numberStyle = .CurrencyStyle
        if let currencyString = currencyFormatter.stringFromNumber(newValue) {
            return (currencyString, cursorPosition + (currencyString.length - text.length))
        }
        return (text, cursorPosition)
    }

    private func formatDate(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 10 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(2, "\\"), (4, "\\")])
    }

    private func formatCreditCardExpirationDate(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 5 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(2, "\\")])
    }

    private func formatCreditCardSixteenDigits(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 19 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(4, " "), (8, " "), (12, " ")])
    }

    private func formatCreditCardFifteenDigits(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            guard isDigit(Character(newInput)) && text.length < 17 else {
                return (text, cursorPosition)
            }
        }

        return removeNonDigitsAndAddCharacters(text, newInput: newInput, range: range, cursorPosition: cursorPosition, characters: [(4, " "), (10, " ")])
    }

    private func formatCreditCardCVVThreeDigits(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        return limitToDigitsAndLength(3, text: text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    private func formatCreditCardCVVFourDigits(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        return limitToDigitsAndLength(4, text: text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    private func limitToDigitsAndLength(length: Int, text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        if newInput != "" {
            if text.length == length {
                return (text, cursorPosition)
            } else if !isDigit(Character(newInput)) {
                return (text, cursorPosition)
            }
        }

        return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
    }

    private func limitToLength(limit: Int) -> ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int)) {

        func limitText(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if text.length == limit && newInput != "" {
                return (text, cursorPosition)
            }
            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitText
    }

    private func limitToDigitsWithLength(limit: Int) -> ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int)) {

        func limitText(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if newInput != "" {
                guard isDigit(Character(newInput)) && text.length < limit else {
                    return (text, cursorPosition)
                }
            }

            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitText
    }

    private func limitToCharacterSet(set: NSCharacterSet) -> ((text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int)) {

        func limitToSet(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
            if newInput != "" {
                guard newInput.rangeOfCharacterFromSet(set) != nil else {
                    return (text, cursorPosition)
                }
            }

            return resultingString(text, newInput: newInput, range: range, cursorPosition: cursorPosition)
        }

        return limitToSet
    }

    // MARK: Validators

    private func validateCurrency(text: String) -> Bool {
        currencyFormatter.numberStyle = .CurrencyStyle
        let number = currencyFormatter.numberFromString(text) ?? 0

        return number.doubleValue > 0.0
    }

    private func isLength(length: Int) -> ((text: String) -> Bool) {

        func checkLength(text: String) -> Bool {
            return text.length == length
        }

        return checkLength
    }

    private func hasLength(text: String) -> Bool {
        return text.length > 0
    }

    // MARK:- Characters

    private func isDigit(character: Character) -> Bool {
        return isDigitOrCharacter("", character: character)
    }

    private func isDigitOrCharacter(additionalCharacters: String, character: Character) -> Bool {
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let fullSet = NSMutableCharacterSet(charactersInString: additionalCharacters)
        fullSet.formUnionWithCharacterSet(digits)

        if isCharacter(character, aMemberOf: fullSet) {
            return true
        }
        return false
    }

    func resultingString(text: String, newInput: String, range: NSRange, cursorPosition: Int) -> (String, Int) {
        guard range.location >= 0 else {
            return (text, cursorPosition)
        }

        let newText = (text as NSString).stringByReplacingCharactersInRange(range, withString: newInput)
        return (newText, cursorPosition + (newText.length - text.length))
    }

    private func removeNonDigits(text: String, cursorPosition: Int) -> (String, Int) {
        var originalCursorPosition = cursorPosition
        let theText = text
        var digitsOnlyString = ""
        for var i = 0; i < theText.length; i++ {
            let characterToAdd = theText[i]
            if isDigit(characterToAdd) {
                let stringToAdd = String(characterToAdd)
                digitsOnlyString.appendContentsOf(stringToAdd)
            } else if i < cursorPosition {
                originalCursorPosition--
            }
        }

        return (digitsOnlyString, originalCursorPosition)
    }

    func insertCharactersAtIndexes(text: String, characters: [(Int, Character)], cursorPosition: Int) -> (String, Int) {
        var stringWithAddedChars = ""
        var newCursorPosition = cursorPosition

        for var i = 0; i < text.length; i++ {
            for (index, char) in characters {
                if index == i {
                    stringWithAddedChars.append(char)
                    if i < cursorPosition {
                        newCursorPosition++
                    }
                }
            }

            let characterToAdd = text[i]
            let stringToAdd = String(characterToAdd)
            stringWithAddedChars.appendContentsOf(stringToAdd)
        }

        return (stringWithAddedChars, newCursorPosition)
    }

    func isCharacter(c: Character, aMemberOf set: NSCharacterSet) -> Bool {
        return set.characterIsMember(String(c).utf16.first!)
    }

    private func removeNonDigitsAndAddCharacters(text: String, newInput: String, range: NSRange, cursorPosition: Int, characters: [(Int, Character)]) -> (String, Int) {
        let (onlyDigitsText, cursorPos) = removeNonDigits(text, cursorPosition: cursorPosition)
        let correctedRange = NSRange(location: range.location + (cursorPos - cursorPosition), length: range.length)
        let (newText, cursorAfterEdit) = resultingString(onlyDigitsText, newInput: newInput, range: correctedRange, cursorPosition: cursorPos)
        let (withCharacters, newCursorPosition) = insertCharactersAtIndexes(newText, characters: characters, cursorPosition: cursorAfterEdit)
        return (withCharacters, newCursorPosition)
    }
}
