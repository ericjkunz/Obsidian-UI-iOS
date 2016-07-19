//
//  LayerAnimation.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import QuartzCore

class LayerAnimation: NSObject {

    var completionClosure: ((finished: Bool)-> ())? = nil
    var layer: CALayer!

    class func animation(layer: CALayer, duration: TimeInterval, delay: TimeInterval, animations: (() -> ())?, completion: ((finished: Bool)-> ())?) -> LayerAnimation {

        let animation = LayerAnimation()

        dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay * Double(NSEC_PER_SEC))).after(DispatchTime.nowwhen: DispatchQueue.main()) {
            var animationGroup: CAAnimationGroup?
            let oldLayer = self.animatableLayerCopy(layer)
            animation.completionClosure = completion

            if let layerAnimations = animations {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                layerAnimations()
                CATransaction.commit()
            }

            animationGroup = self.groupAnimationsForDifferences(oldLayer, newLayer: layer)

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

    class func groupAnimationsForDifferences(oldLayer: CALayer, newLayer: CALayer) -> CAAnimationGroup? {
        var animationGroup: CAAnimationGroup?
        var animations = Array<CABasicAnimation>()

        if !CATransform3DEqualToTransform(oldLayer.transform, newLayer.transform) {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(CATransform3D: oldLayer.transform)
            animation.toValue = NSValue(CATransform3D: newLayer.transform)
            animations.append(animation)
        }

        if !oldLayer.bounds.equalTo(newLayer.bounds) {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(CGRect: oldLayer.bounds)
            animation.toValue = NSValue(CGRect: newLayer.bounds)
            animations.append(animation)
        }

        if !oldLayer.frame.equalTo(newLayer.frame) {
            let animation = CABasicAnimation(keyPath: "frame")
            animation.fromValue = NSValue(CGRect: oldLayer.frame)
            animation.toValue = NSValue(CGRect: newLayer.frame)
            animations.append(animation)
        }

        if !oldLayer.position.equalTo(newLayer.position) {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = NSValue(CGPoint: oldLayer.position)
            animation.toValue = NSValue(CGPoint: newLayer.position)
            animations.append(animation)
        }

        if oldLayer.opacity != newLayer.opacity {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = oldLayer.opacity
            animation.toValue = newLayer.opacity
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

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let completion = completionClosure {
            completion(finished: true)
        }
    }

}
