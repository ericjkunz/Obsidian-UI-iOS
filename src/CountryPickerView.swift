//
//  CountryPickerView.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/18/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
The PickerDelegate protocol defines messages sent to a picker delegate
involving tapped buttons of its accessory view and changing selection.
A CountryPickerDelegate must also conform to the PickerDelegate protocol.
*/
public protocol CountryPickerDelegate: PickerInputDelegate {
    func pickerDidChangeCountry(picker: CountryPicker)
}

/// A picker view with all known legal countries.
/// The picker defaults to the country of the device's current locale.
public class CountryPicker: PickerInputView {

    convenience init() {
        self.init(frame: UIScreen.mainScreen().bounds)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCountries()
    }

    /// :nodoc:
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The delegate of a CountryPicker must adopt the CountryPickerDelegate protocol. Methods of the protocol help
    public var countryPickerDelegate: CountryPickerDelegate? {
        didSet {
            delegate = countryPickerDelegate
        }
    }

    /// The ISO code of the selected country
    public private(set) var countryCode: String?

    /// The name of the selected country. Set this to change the picker to the specified country
    /// as well as the text of the field.
    public var countryName: String? {
        didSet {
            if let name = countryName {
                if let index = alphabeticalCountryNames.index(of: name) {
                    pickerView.selectRow(index, inComponent: 0, animated: true)
                    textField?.text = countryName
                } else {
                    assertionFailure("Country is not a known legal country.")
                }
            }
        }
    }

    private var alphabeticalCountryNames = [String]()
    private var codesAndCountries = [String : String]()

    /// :nodoc:
    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    func loadCountries() {
        let currentLocale = Locale.current
        let countryCodes = Locale.isoCountryCodes

        for countryCode in countryCodes {
            let countryName = currentLocale.displayName(forKey: Locale.Key.countryCode, value: countryCode)
            if let name = countryName {
                codesAndCountries[countryCode] = name
            }
        }

        let allCountryNames = codesAndCountries.values
        alphabeticalCountryNames = allCountryNames.sort()
    }

    private func updateCountry() {
        countryName = alphabeticalCountryNames[pickerView.selectedRowInComponent(0)]
        if let name = countryName {
            countryCode = codesAndCountries[name]
        }
    }

    private func updateText() {
        textField?.text = countryName
    }

    /// Sets the picker view to the country of the current user's locale
    public func selectCurrentUserLocale() {
        
        let currentLocale = Locale.current
        
        guard let currentCountryCode = currentLocale.object(forKey: Locale.Key.countryCode) as? String else {
            return
        }
        
        let currentCountryName = codesAndCountries[currentCountryCode]
        
        countryName = currentCountryName
        countryCode = currentCountryCode
    }

    // MARK: Picker View Delegate

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let title = alphabeticalCountryNames[row]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        let textAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSParagraphStyleAttributeName : paragraphStyle]
        let attributedTitle = AttributedString(string: title, attributes: textAttributes)

        let label = UILabel()
        label.attributedText = attributedTitle
        return label
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateCountry()
        updateText()
        countryPickerDelegate?.pickerDidChangeCountry(self)
    }

    public override func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public override func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alphabeticalCountryNames.count
    }

    public func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return frame.size.width
    }
}
