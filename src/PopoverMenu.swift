//
//  PopoverMenu.swift
//  Alfredo
//
//  Created by Nick Lee on 8/19/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

private class PopoverMenuTableViewController: UITableViewController {

    // MARK: Constants

    private static let ReuseIdentifier = "Cell"

    // MARK: Properties

    private var items: [PopoverItem]!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PopoverMenuTableViewController.ReuseIdentifier)
    }

    // MARK: UITableViewDataSource

    private override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    private override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    private override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopoverMenuTableViewController.ReuseIdentifier, for: indexPath as IndexPath)

        let item = items[indexPath.row]

        cell.textLabel?.text = item.title
        cell.textLabel?.font = item.textFont
        cell.textLabel?.textColor = item.textColor
        cell.textLabel?.textAlignment = item.textAlignment

        cell.selectionStyle = .none
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }

    // MARK: UITableViewDelegate

    private override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].height
    }

    private override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = items[indexPath.row]

        // Always a solid fix :)
        (0.1).seconds.delay {
            self.presentingViewController?.dismiss(animated: true, completion: item.selection)
        }

    }

}

public struct PopoverItem {

    /// :nodoc:
    public typealias Selection = () -> ()

    /// The item's title
    public var title: String

    /// The item's height
    public var height: CGFloat = 54.0

    /// The text color that will be used for the item's label
    public var textColor = UIColor(red:0, green:0.58, blue:1, alpha:1)

    /// The font that will be used for the item's label
    public var textFont = UIFont.systemFont(ofSize: UIFont.systemFontSize())

    /// The text alignment that will be used for the item's label
    public var textAlignment: NSTextAlignment = .center

    /// The closure that will be executed upon selection of the item
    public var selection: Selection?

    /**
    Creates a new PopoverItem

    - parameter title: The item's title
    - parameter selection: The closure that will be executed upon selection of the item

    - returns: A newly initialized PopoverItem.

    */
    public init(title: String, selection: Selection? = nil) {
        self.title = title
        self.selection = selection
    }

}

public final class PopoverMenu {

    private let controller = PopoverMenuTableViewController()

    /// The width of the popover
    public var width: CGFloat = 180.0


    /// The underlying UIPopoverPresentationController
    public var popoverPresentationController: UIPopoverPresentationController {
        return controller.popoverPresentationController!
    }

    /**
    Creates a new PopoverMenu

    - parameter items: An array of PopoverItems that should be displayed in the menu

    - returns: A newly initialized PopoverItem.

    */
    public init(items: [PopoverItem]) {
        controller.items = items
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.backgroundColor = UIColor.white()
    }

    /**
    Presents the PopoverMenu

    - parameter inView: The view in which the popover should be displayed
    - parameter sourceRect: The frame from which the popover should be displayed (relative to inView)
    - parameter fromController: The view controller from which the popover should be presented

    */
    public func present(inView view: UIView, sourceRect rect: CGRect, fromController c: UIViewController) {
        configurePopover()
        controller.popoverPresentationController?.sourceView = view
        controller.popoverPresentationController?.sourceRect = rect
        presentPopover(c)
    }

    /**
    Presents the PopoverMenu

    - parameter barbuttonItem: The barButtonItem to use as an anchor point
    - parameter fromController: The view controller from which the popover should be presented

    */
    public func present(barbuttonItem: UIBarButtonItem, fromController c: UIViewController) {
        configurePopover()
        controller.popoverPresentationController?.barButtonItem = barbuttonItem
        presentPopover(c)
    }

    private func configurePopover() {
        let screenHeight = UIScreen.main().bounds.height
        let height = controller.items.reduce(CGFloat(0)) { return $0 + $1.height }
        let constrainedHeight = min(height, floor(screenHeight / 2.0))
        controller.tableView.isScrollEnabled = height != constrainedHeight
        controller.preferredContentSize = CGSize(width: width, height: constrainedHeight)
    }

    private func presentPopover(_ c: UIViewController) {
        controller.present(c)
    }

}
