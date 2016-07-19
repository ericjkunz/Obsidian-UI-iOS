//
//  LayerAnimation.swift
//  Obsidian UI
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import QuartzCore

class LayerAnimation: NSObject, CAAnimationDelegate {

    var completionClosure: ((finished: Bool)-> ())? = nil
    var layer: CALayer!

    class func animation(layer: CALayer, duration: TimeInterval, delay: DispatchWallTime, animations: (() -> ())?, completion: ((finished: Bool)-> ())?) -> LayerAnimation {

        let animation = LayerAnimation()

        DispatchQueue.main.after(walltime: delay) {
            var animationGroup: CAAnimationGroup?
            let oldLayer = self.animatableLayerCopy(layer: layer)
            animation.completionClosure = completion

            if let layerAnimations = animations {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                layerAnimations()
                CATransaction.commit()
            }

            animationGroup = self.groupAnimationsForDifferences(old: oldLayer, new: layer)

            if let differenceAnimation = animationGroup {
                differenceAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                differenceAnimation.duration = duration
                differenceAnimation.beginTime = CACurrentMediaTime()
                differenceAnimation.delegate = animation
                layer.add(differenceAnimation, forKey: nil)
            } else {
                if let completion = animation.completionClosure {
                    completion(finished: true)
                }
            }
        }

        return animation
    }

    class func groupAnimationsForDifferences(old: CALayer, new: CALayer) -> CAAnimationGroup? {
        var animationGroup: CAAnimationGroup?
        var animations = Array<CABasicAnimation>()

        if !CATransform3DEqualToTransform(old.transform, new.transform) {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: old.transform)
            animation.toValue = NSValue(caTransform3D: new.transform)
            animations.append(animation)
        }

        if !old.bounds.equalTo(new.bounds) {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(cgRect: old.bounds)
            animation.toValue = NSValue(cgRect: new.bounds)
            animations.append(animation)
        }

        if !old.frame.equalTo(new.frame) {
            let animation = CABasicAnimation(keyPath: "frame")
            animation.fromValue = NSValue(cgRect: old.frame)
            animation.toValue = NSValue(cgRect: new.frame)
            animations.append(animation)
        }

        if !old.position.equalTo(new.position) {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = NSValue(cgPoint: old.position)
            animation.toValue = NSValue(cgPoint: new.position)
            animations.append(animation)
        }

        if old.opacity != new.opacity {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = old.opacity
            animation.toValue = new.opacity
            animations.append(animation)
        }

        if !animations.isEmpty {
            animationGroup = CAAnimationGroup()
            animationGroup!.animations = animations
        }

        return animationGroup
    }

    class func animatableLayerCopy(layer: CALayer) -> CALayer {

        let layerCopy = CALayer()

        layerCopy.opacity = layer.opacity
        layerCopy.transform = layer.transform
        layerCopy.bounds = layer.bounds
        layerCopy.position = layer.position

        return layerCopy
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completion = completionClosure {
            completion(finished: true)
        }
    }

}
