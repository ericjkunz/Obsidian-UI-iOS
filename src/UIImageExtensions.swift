//
//  UIImageExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UIImage {

    // MARK: UI Helpers

    /// Returns a UIImageView with its bounds and contents pre-populated by the receiver
    public var imageView: UIImageView {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let view = UIImageView(frame: bounds)
        view.image = self
        view.contentMode = .Center
        return view
    }

}

internal extension UIImage {

    internal func decodedImage() -> UIImage? {
        return decodedImage(scale: scale)
    }

    internal func decodedImage(scale scale: CGFloat) -> UIImage? {

        let imageRef = CGImage

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)

        let context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, bitmapInfo.rawValue)

        if let context = context {
            let rect = CGRect(0, 0, CGFloat(CGImageGetWidth(imageRef)), CGFloat(CGImageGetHeight(imageRef)))
            CGContextDrawImage(context, rect, imageRef)
            let decompressedImageRef = CGBitmapContextCreateImage(context)
            if let decompressed = decompressedImageRef {
                return UIImage(CGImage: decompressed, scale: scale, orientation: imageOrientation)
            }
        }

        return nil

    }
    
    func cropToBounds(rect: CGRect) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: self.CGImage!)
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage!, rect)!
        let image: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    func maskWithImage(mask: UIImage) -> UIImage? {
        let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), 8, 0, CGColorSpaceCreateDeviceRGB(), CGImageAlphaInfo.PremultipliedLast.rawValue)
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        CGContextClipToMask(ctx, imageRect, mask.CGImage)
        CGContextDrawImage(ctx, imageRect, self.CGImage)
        
        if let resultImage = CGBitmapContextCreateImage(ctx) {
            return UIImage(CGImage: resultImage)
        }
        else {
            return nil
        }
    }
    
    func resizeImage(size: CGSize) -> UIImage {
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(size.width / self.size.width, size.height / self.size.height))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }

}
