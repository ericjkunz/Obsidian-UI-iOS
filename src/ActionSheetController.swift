//
//  ActionSheetController.swift
//  Alfredo
//
//  Created by Nick Lee on 9/21/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public struct Action {

    // MARK: Types

    public typealias Handler = (action: Action) -> ()

    // MARK: Properties

    /// The closure to be executed when the corresponding action is selected
    public let handler: Handler?

    /// The action's title
    public let title: String

    /// The color of the action's title label
    public let textColor: UIColor

    /// The highlighted color of the action's title label
    public let highlightedTextColor: UIColor

    /// The action button's background color
    public let backgroundColor: UIColor

    /// The action button's highlighted background color
    public let highlightedBackgroundColor: UIColor

    /// The action button's height
    public let height: CGFloat

    /// The font used for the action's title label
    public let font: UIFont

    /**
    Creates a new Action

    - parameter title: The action's title
    - parameter textColor: The color of the action's title label
    - parameter highlightedTextColor: The highlighted color of the action's title label
    - parameter backgroundColor: The action button's background color
    - parameter highlightedBackgroundColor: The action button's highlighted background color
    - parameter height: The action button's height
    - parameter font: The font used for the action's title label
    - parameter handler: The closure to be executed when the corresponding action is selected

    - returns: An Action object

    */
    public init(title: String, textColor: UIColor = UIColor.black(), highlightedTextColor: UIColor? = nil, backgroundColor: UIColor = UIColor.white(), highlightedBackgroundColor: UIColor? = nil, height: CGFloat = 64, font: UIFont = UIFont.boldSystemFont(ofSize: 20.0), handler: Handler?) {
        self.title = title
        self.textColor = textColor
        self.highlightedTextColor = highlightedTextColor ?? textColor
        self.backgroundColor = backgroundColor
        self.highlightedBackgroundColor = highlightedBackgroundColor ?? blendColor(backgroundColor, ActionSheetController.ActionSheetControllerConstants.ButtonDimmingColor, -, true)
        self.height = height
        self.font = font
        self.handler = handler
    }

}

private class ActionSheetPresentationController: UIPresentationController {

    // MARK: Properties

    private var height: CGFloat = 0

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = ActionSheetController.ActionSheetControllerConstants.DimmingColor
        return view
        }()

    // MARK: Overrides

    private override func presentationTransitionWillBegin() {

        super.presentationTransitionWillBegin()

        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        dimmingView.addGestureRecognizer(tap)

        containerView!.addSubview(dimmingView)
        containerView!.addSubview(presentedView()!)

        let coordinator = presentingViewController.transitionCoordinator()

        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 1.0
            }, completion: nil)

    }

    private override func dismissalTransitionWillBegin() {

        let coordinator = presentingViewController.transitionCoordinator()

        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.0
            }, completion: nil)

    }

    private override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        dimmingView.removeFromSuperview()
    }


    private override func frameOfPresentedViewInContainerView() -> CGRect {
        if let bounds = containerView?.bounds {
            return CGRect(
                origin: CGPoint(
                    x: 0,
                    y: bounds.height - height
                ),
                size: CGSize(width:
                    bounds.width,
                    height: height
                )
            )
        }
        return CGRect.zero
    }

    // MARK: Actions

    private dynamic func dismissController(_ sender: UIGestureRecognizer) {
        presentingViewController.dismiss(animated: true) { () -> Void in
            NotificationCenter.default.post(name: "actionSheetDismissedByTapAbove" as NSNotification.Name, object: self)
        }
    }

}

/**
The ActionSheetDelegate protocol defines the message sent to an action
sheet delegate when dismissing the view.

*/
public protocol ActionSheetDelegate: class {
    /**
    Tells the delegate that the action sheet was dismissed.

    - parameter actionSheet the action sheet that was dismissed

    */
    func actionSheetDidDismissByTappingOutside(_ actionSheet: ActionSheetController)
}

public final class ActionSheetController: UIViewController, UIViewControllerTransitioningDelegate {

    // MARK: Properties

    /// The actions that will be presented by the ActionSheetController
    public let actions: [Action]

    /// An action sheet delegate responds to presentation-related messages
    public weak var delegate: ActionSheetDelegate?

    // MARK: Constants

    private struct ActionSheetControllerConstants {
        static let DimmingColor = UIColor(red:0.14, green:0.14, blue:0.15, alpha:0.7)
        static let ButtonDimmingColor = UIColor.white().withAlphaComponent(0.1)
    }

    // MARK: Private Properties

    private var buttons: [UIButton] = []

    // MARK: Initialization

    /**
    Initializes a new ActionSheetController with the passed actions

    - parameter actions The actions to display

    - returns: An initialized ActionSheetController

    */
    public init(actions actionSheetActions: [Action]) {
        actions = actionSheetActions.reversed()
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Status Bar

    /// :nodoc:
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle() ?? super.preferredStatusBarStyle()
    }

    /// :nodoc:
    public override func prefersStatusBarHidden() -> Bool {
        return presentingViewController?.prefersStatusBarHidden() ?? super.prefersStatusBarHidden()
    }

    /// :nodoc:
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return presentingViewController?.preferredStatusBarUpdateAnimation() ?? super.preferredStatusBarUpdateAnimation()
    }

    // MARK: Lifecycle

    /// :nodoc:
    public override func loadView() {
        view = UIView()
    }

    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Create the buttons

        buttons = actions.map({ action -> UIButton in
            let button = ColorButton(type: .custom)

            button.translatesAutoresizingMaskIntoConstraints = false

            button.setTitle(action.title, for: .normal)

            button.setTitleColor(action.textColor, for: .normal)
            button.setTitleColor(action.highlightedTextColor, for: .highlighted)

            button.setBackgroundColor(color: action.backgroundColor, forState: .normal)
            button.setBackgroundColor(color: action.highlightedBackgroundColor, forState: .highlighted)

            button.titleLabel?.font = action.font

            addHandler(control: button, events: .touchUpInside, target: self, handler: self.dynamicType.buttonSelected)

            return button
        })

        // Add the buttons

        buttons.forEach(view.addSubview)

        // Constrain the buttons horizontally

        let horizontalConstraints = buttons.reduce([NSLayoutConstraint]()) { arr, button in
            let views = [ "button" : button ]
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[button]-0-|", options: [], metrics: nil, views: views)
            return arr + constraints
        }

        view.addConstraints(horizontalConstraints)

        // Constrain the buttons vertically

        let verticalConstraints = buttons.enumerated().reduce([NSLayoutConstraint]()) { arr, el in
            let action = self.actions[el.index]
            let pin = el.index == 0 ? self.view : buttons[el.index - 1]
            let targetAttribute: NSLayoutAttribute = el.index == 0 ? .Bottom : .Top
            let constraints = [
                NSLayoutConstraint(item: el.element, attribute: .Bottom, relatedBy: .Equal, toItem: pin, attribute: targetAttribute, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: el.element, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: action.height)
            ]
            return arr + constraints
        }

        view.addConstraints(verticalConstraints)

        NotificationCenter.default.addObserver(self, selector: #selector(ActionSheetController.userTappedAbove), name: "actionSheetDismissedByTapAbove" as NSNotification.Name, object: nil)
    }

    // MARK: Actions

    private var selectedButton = false

    private func buttonSelected(_ sender: UIButton) {
        selectedButton = true
        if let index = buttons.index(of: sender) {
            let action = actions[index]
            dismiss(animated: true) {
                action.handler?(action: action)
            }
        }
    }

    func userTappedAbove() {
        delegate?.actionSheetDidDismissByTappingOutside(self)
    }

    // MARK: UIViewControllerTransitioningDelegate

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
        controller.height = actions.reduce(0) { $0 + $1.height }
        return controller
    }

}
