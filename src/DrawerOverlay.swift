//
//  DrawerOverlayViewController.swift
//  Alfredo
//
//  Created by Nick Lee on 8/26/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit


private struct DrawerPresentationControllerConstants {
    static let AnimationDuration: TimeInterval = 0.25
    static let DefaultDrawerWidth: CGFloat = 320.0
    static let DefaultBackgroundColor = UIColor.black().withAlphaComponent(0.75)
}

/// The side on which the drawer should be presented
public enum DrawerSide: Int {
    case Left
    case Right
}

private final class DrawerPresentationController: UIPresentationController {
    
    // MARK: Public Properties
    
    private var dimmingColor: UIColor = DrawerPresentationControllerConstants.DefaultBackgroundColor
    
    // MARK: Private Properties
    
    private let side: DrawerSide
    private let dimmingView = UIView()
    
    // MARK: Initialization
    
    private init(presentedViewController: UIViewController!, presentingViewController: UIViewController!, side: DrawerSide) {
        self.side = side
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: Presentation
    
    private override func presentationTransitionWillBegin() {
        
        super.presentationTransitionWillBegin()
        
        dimmingView.backgroundColor = dimmingColor
        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissController:")
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
        
        let drawerWidth = DrawerPresentationControllerConstants.DefaultDrawerWidth
        
        switch side {
        case .Left:
            return CGRect(origin: CGPoint.zero, size: CGSize(width: drawerWidth, height: containerView!.height))
        case .Right:
            return CGRect(origin: CGPoint(x: containerView!.width - drawerWidth, y: 0.0), size: CGSize(width: drawerWidth, height: containerView!.height))
        }
        
    }
    
    // MARK: Actions
    
    private dynamic func dismissController(sender: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
}

private final class DrawerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    private let side: DrawerSide
    
    private init(side: DrawerSide, presenting: Bool) {
        self.side = side
        self.presenting = presenting
        super.init()
    }
    
    @objc private func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DrawerPresentationControllerConstants.AnimationDuration
    }
    
    @objc private func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)
        let toController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)
        
        if let targetController = (presenting ? toController : fromController) {
            
            let destinationFrame = transitionContext.finalFrame(for: targetController)
            var originFrame = destinationFrame
            
            var offset: CGFloat!
            
            switch side {
            case .Left:
                offset = -destinationFrame.width
            case .Right:
                offset = destinationFrame.width
            }
            
            originFrame.offsetInPlace(dx: offset, dy: 0)
            
            targetController.view.frame = presenting ? originFrame : destinationFrame
            transitionContext.containerView().addSubview(targetController.view)
            
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                targetController.view.frame = self.presenting ? destinationFrame : originFrame
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })
            
        }
        
    }
    
}

final class _DrawerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let side: DrawerSide
    
    init(from side: DrawerSide) {
        self.side = side
        super.init()
    }
    
    @objc func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presentingViewController: presenting, side: side)
    }
    
    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimationController(side: side, presenting: true)
    }
    
    @objc func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimationController(side: side, presenting: false)
    }
    
    private var delegates: [DrawerSide : UIViewControllerTransitioningDelegate] = [:]
    
    func DrawerTransitioningDelegate(from: DrawerSide) -> UIViewControllerTransitioningDelegate {
        let delegate = delegates[side] ?? _DrawerTransitioningDelegate(from: side)
        delegates[side] = delegate
        return delegate
    }
    
}
