//
//  UICollectionViewExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UICollectionView {

    // MARK: Nib Registration

    /**
    Registers a cell nib of the passed name, using the name as its reuse identifier

    - parameter name: The name of the .nib file, which will also be used as the cell's reuse identifier

    */
    public func registerCellNib(name: String) {
        let nib = NibCache[name] ?? UINib(nibName: name, bundle: Bundle.main)
        NibCache[name] = nib
        register(nib, forCellWithReuseIdentifier: name)
    }

    /**
    Registers a header nib of the passed name, using the name as its reuse identifier

    - parameter name: The name of the .nib file, which will also be used as the header's reuse identifier

    */
    public func registerSectionHeaderNib(name: String) {
        let nib = NibCache[name] ?? UINib(nibName: name, bundle: Bundle.main)
        NibCache[name] = nib
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: name)
    }

    /**
    Registers a footer nib of the passed name, using the name as its reuse identifier

    - parameter name: The name of the .nib file, which will also be used as the footer's reuse identifier

    */
    public func registerSectionFooterNib(name: String) {
        let nib = NibCache[name] ?? UINib(nibName: name, bundle: Bundle.main)
        NibCache[name] = nib
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: name)
    }


    // MARK: Reloading

    /**
    Reloads the passed sections, with or without animation

    - parameter animated: Whether or not the transition should be animated
    - parameter sections: The sections to reload

    */
    public func refreshSections(animated: Bool = false, _ sections: [Int]) {

        let indexSet = NSMutableIndexSet()

        for index in sections {
            indexSet.add(index)
        }

        let animations = {
            self.reloadSections(indexSet as IndexSet)
        }

        if animated {
            animations()
        } else {
            UIView.performWithoutAnimation(animations)
        }

    }

    // MARK: Cell Identification

    /// The cell with the greatest visible area
    var mostVisibleCell: UICollectionViewCell? {

        let visibleIndexPaths = self.indexPathsForVisibleItems()
        let attributes = visibleIndexPaths.map({ self.collectionViewLayout.layoutAttributesForItem(at: $0) }).filter({ $0 != nil }).map({ $0! })
        let deltas = attributes.map({ $0.frame.origin.distance(fromPoint: self.contentOffset) })

        if !visibleIndexPaths.isEmpty {
            if let i = deltas.index(of: deltas.min()!) {
                return cellForItem(at: visibleIndexPaths[i])
            }
        }

        return nil
    }

    /// The index path of the cell with the greatest visible area
    var mostVisibleIndexPath: NSIndexPath? {
        if let cell = mostVisibleCell {
            return indexPath(for: cell)
        }
        return nil
    }

}
