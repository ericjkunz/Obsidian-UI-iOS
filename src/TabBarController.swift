//
//  TabBarController.swift
//  Alfredo
//
//  Created by Nick Lee on 8/21/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public protocol TabBarDelegate: class {

    /// returns the currently selected tab index
    var selectedTabIndex: Int { get }

    /// Called when the user selects a tab
    func selectTab(index: Int)

    /// A computed array of the tab names
    var tabNames: [String] { get }

}

public class TabBarController: UIViewController, TabBarDelegate {

    // MARK: Public Properties

    /// The view controllers managed by the tab bar
    public var viewControllers: [UIViewController] = [] {
        didSet {
            updateTabs()
            selectTab(0)
        }
    }

    /// A computed array of the tab names
    public var tabNames: [String] {
        return viewControllers.map { $0.title ?? L("Untitled") } ?? []
    }

    /// The index of the currently selected tab
    public private(set) var selectedTabIndex = 0

    /// The tab bar's height
    public var tabBarHeight: CGFloat = 50 {
        didSet {
            layoutTabBar()
        }
    }

    // MARK: Private Properties

    /// The controller's tab bar.  Defaults to nil, but will result in a crash if not set.
    public var tabBar: BaseTabBar! {
        didSet {
            tabBar.delegate = self
            view.addSubview(tabBar)
            layoutTabBar()
            updateTabs()
        }
    }

    private var controllerContainer: UIView = UIView()
    private var contentViewController: UIViewController?

    // MARK: Initialization

    /// :nodoc:
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Tab Bar Management

    private func layoutTabBar() {

        tabBar.x = 0
        tabBar.y = view.height - tabBarHeight
        tabBar.width = view.width
        tabBar.height = tabBarHeight

        controllerContainer.x = 0
        controllerContainer.y = 0
        controllerContainer.width = view.width
        controllerContainer.height = view.height - tabBarHeight

    }

    private func updateTabs() {
        tabBar?.layout()
    }

    /**
    Selects a tab

    - parameter tab: The index of the tab to select.

    */
    public func selectTab(tab: Int) {

        selectedTabIndex = tab
        tabBar.selectTab(tab)

        if let c = contentViewController {
            c.willMove(toParentViewController: nil)
            c.view.removeFromSuperview()
            c.removeFromParentViewController()
        }

        let new = viewControllers[tab]
        self.addChildViewController(new)
        new.view.frame = controllerContainer.bounds
        controllerContainer.addSubview(new.view)
        new.didMove(toParentViewController: self)

        contentViewController = new

    }

    // MARK: Lifecycle

    /// :nodoc:
    public override func loadView() {
        super.loadView()
        view.addSubview(controllerContainer)
    }

    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    /// :nodoc:
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTabBar()
    }

}
