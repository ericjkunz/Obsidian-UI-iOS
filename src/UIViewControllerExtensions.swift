//
//  UIViewControllerExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/22/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

extension UIViewController {

    /**
    Presents a form sheet. iPad only.

    - parameter controller: The controller to present
    - parameter navigationController: The navigation controller in which the presented controller should be housed.  Passing nil will present controller without any chrome.  Omitting the parameter will use a standard UINavigationController.

    */
    public func presentFormSheet(controller: UIViewController, navigationController: UINavigationController? = UINavigationController()) {
        navigationController?.modalPresentationStyle = .formSheet
        navigationController?.viewControllers = [controller]
        (navigationController ?? controller).present(self)
    }

    /**
    Presents a drawer

    - parameter controller: The controller to present
    - parameter navigationController: The navigation controller in which the presented controller should be housed.  Passing nil will present controller without any chrome.  Omitting the parameter will use a standard UINavigationController.

    */
    public func presentDrawer(controller: UIViewController, side: DrawerSide = .Right, navigationController: UINavigationController? = UINavigationController()) {
        navigationController?.viewControllers = [controller]
        let presented = navigationController ?? controller
        presented.transitioningDelegate = _DrawerTransitioningDelegate(from: side)
        presented.modalPresentationStyle = .custom
        presented.present(self)
    }

    /**
    Presents a view controller modally.

    - parameter sourceController: The controller from which the receiver should be presented.

    */
    public func present(_ sourceController: UIViewController) {
        sourceController.present(self, animated: true, completion: nil)
    }

    /**
    Prompts the user for some text

    - parameter title: The alert's title
    - parameter message: An optional alert message
    - parameter acceptButtontitle: The title for the accept button.  Defaults to "OK"
    - parameter placeholder: The placeholder text for the text field.  Defaults to nil
    - parameter completion: A closure triggered when the user has dismissed the alert

    */
    public func prompt(title: String, message: String?, acceptButtonTitle: String = L("OK"), placeholder: String? = nil, completion: (value: String?) -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        controller.addTextField { (field) -> Void in
            field.placeholder = placeholder
        }

        let ok = UIAlertAction(title: acceptButtonTitle, style: .default) { [weak controller] (action) -> Void in
            if let field = controller?.textFields?[0] {
                completion(value: field.text)
            }
        }

        controller.addAction(ok)

        let cancel = UIAlertAction(title: L("Cancel"), style: .cancel) { (action) -> Void in
            completion(value: nil)
        }

        controller.addAction(cancel)

        controller.present(self)
    }

    /**
    Confirms a destructive operation

    - parameter title: The alert's title.  Defaults to "Are You Sure?"
    - parameter message: An optional alert message
    - parameter acceptButtontitle: The title for the accept button.  Defaults to "Confirm"
    - parameter acceptButtonStyle: The style of the accept button.  Defaults to Destructive
    - parameter completion: A closure triggered when the user has dismissed the alert

    */
    public func confirm(title: String = L("Are You Sure?"), message: String?, acceptButtonTitle: String = L("Confirm"), acceptButtonStyle: UIAlertActionStyle = .destructive, completion: (confirmed: Bool) -> ()) {

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirm = UIAlertAction(title: acceptButtonTitle, style: acceptButtonStyle) { action in
            completion(confirmed: true)
        }

        controller.addAction(confirm)

        let cancel = UIAlertAction(title: L("Cancel"), style: .cancel) { action in
            completion(confirmed: false)
        }

        controller.addAction(cancel)

        controller.present(self)

    }

    // MARK: Activity Display

    private static var indicatorConfigs: [ String : ActivityIndicatorView.Config ] = [:]

    private func findActivityIndicator() -> ActivityIndicatorView? {
        for v in view.subviews {
            if let activityIndicator = v as? ActivityIndicatorView {
                return activityIndicator
            }
        }
        return nil
    }

    /**
    Registers an activity indicator configuration

    - parameter backgroundColor: The background color to be used for activity indicators spawned with this configuration
    - parameter images: An array of images to be animated in the center of the screen while activity is taking place
    - parameter duration: The duration of one cycle through the animation images
    - parameter identifier: An identifier for this configuration, to be used later when calling showActivityIndicator().  If omitted, a default identifier will be used.

    */
    public class func registerActivityIndicatorAnimation(backgroundColor: UIColor, images: [UIImage], duration: TimeInterval, identifier: String = Constants.DefaultIndicatorName, spaceAboveCenter: CGFloat = 0) {
        indicatorConfigs[identifier] = ActivityIndicatorView.Config(backgroundColor: backgroundColor, images: images, duration: duration, spaceAboveCenter: spaceAboveCenter)
    }

    /**
    Displays an activity indicator over the current view

    - parameter identifier: The identifier of the configuration to use.  See UIViewController.registerActivityIndicatorAnimation(...). If omitted, a default identifier will be used.
    - parameter disableScrollingIfNeeded:  Whether or not the scrolling on the controller's root view should be disabled during loading.  Only applies to controllers whose views inherit from UIScrollView.
    - parameter constrainToView: The view to which the activity indicator should be pinned.  Must be a subview of the receiver's view.

    */
    public func showActivityIndicator(identifier: String = Constants.DefaultIndicatorName, disableScrollingIfNeeded: Bool = true, constrainToView constraint: UIView? = nil) {

        guard findActivityIndicator() == nil else {
            Logger.error(closure: "Trying to add an activity indicator to \(view) but there already is one!")
            return
        }

        guard let config = UIViewController.indicatorConfigs[identifier] else {
            fatalError("Couldn't find configuration for identifier \"\(identifier)\" - did you call UIViewController.registerActivityIndicatorAnimation(...)?")
        }

        let activityIndicator = ActivityIndicatorView(frame: view.bounds, config: config)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)

        let constraintTarget = constraint ?? view

        let constraints = [
            NSLayoutConstraint(item: activityIndicator, attribute: .top, relatedBy: .equal, toItem: constraintTarget, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .left, relatedBy: .equal, toItem: constraintTarget, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: constraintTarget, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: constraintTarget, attribute: .height, multiplier: 1.0, constant: 0.0)
        ]

        constraints.forEach { $0.isActive = true }

        activityIndicator.startAnimating()

        if let scrollView = view as? UIScrollView, disableScrollingIfNeeded {
            scrollView.isScrollEnabled = false
        }

        // Force Z position to be very high, mainly for table views
        activityIndicator.layer.zPosition = CGFloat(FLT_MAX - 1.0)

    }

    /**
    Hides any activity indicators that are present over the current view

    - parameter enableScrollingIfNeeded:  Whether or not the scrolling on the controller's root view should be re-enabled.  Only applies to controllers whose views inherit from UIScrollView.

    */
    public func hideActivityIndicator(enableScrollingIfNeeded: Bool = true) {

        if let scrollView = view as? UIScrollView , enableScrollingIfNeeded == true {
            scrollView.isScrollEnabled = true
        }

        while let indicator = findActivityIndicator() {
            indicator.removeFromSuperview()
        }

    }

}
