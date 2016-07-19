//
//  FloatingView.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/2/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

/**
A view that positions itself based on the scrolling of its superview.
Recommended use is as a header or footer view for a UITableView.

This view can float in place (FloatAtTop, FloatAtBottom, or FloatInPlace)
regardless of its superview's scrolling or it can stick to the top (FloatAboveContent) or
bottom (FloatBelowContent) of the superview until the content is scrolled and pushes it out of view.

*/
public class FloatingView: UIView {

    /// How the view behaves when its superview is scrolled
    public enum FloatBehavior {
        /// View will stay above content and move out of view when scrolled.
        case FloatAboveContent
        /// View will stay below content and move out of view when scrolled.
        case FloatBelowContent
        /// View will always be visible at top of view and not effected by scrolling.
        case FloatAtTop
        /// View will always be visible at bottom of view and not effected by scrolling.
        case FloatAtBottom
        /// View will stay in its visible position.
        case FloatInPlace
    }

    /// How the view behaves when its superview is scrolled
    public var floatBehavior = FloatBehavior.FloatAtTop

    /// Call this inside the scrollViewDidScroll of your UIScrollViewDelegate or UITableViewDelegate.
    public func scrollViewDidScroll(scrollView: UIScrollView) {

        let verticalScrollDistance = scrollView.contentOffset.y
        let topContentInset = scrollView.contentInset.top
        let restingScrollPosition = scrollView.contentInset.top + self.frame.size.height
        var newFrame = self.frame
        var newFrameOriginY = newFrame.origin.y
        let contentHeight = scrollView.contentSize.height

        switch floatBehavior {
        case .FloatAboveContent:
            if verticalScrollDistance <= -topContentInset {
                newFrameOriginY = verticalScrollDistance + restingScrollPosition
            }
            break
        case .FloatBelowContent:
            if verticalScrollDistance > (contentHeight + newFrame.height - scrollView.height) {
                newFrameOriginY = scrollView.height - newFrame.height + verticalScrollDistance
            }
            break
        case .FloatAtTop:
            newFrameOriginY = verticalScrollDistance
            break
        case .FloatAtBottom:
            newFrameOriginY = verticalScrollDistance + scrollView.height - newFrame.height
            break
        case .FloatInPlace:
            newFrameOriginY += verticalScrollDistance
            break
        }

        newFrame.origin.y = newFrameOriginY
        frame = newFrame
    }

}
