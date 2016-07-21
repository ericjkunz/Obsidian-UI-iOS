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
        view.contentMode = .center
        return view
    }

}

internal extension UIImage {

    internal func decodedImage() -> UIImage? {
        return decodedImage(scale: scale)
    }

    internal func decodedImage(scale: CGFloat) -> UIImage? {

        guard let imageRef = cgImage else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let context = CGContext(data: nil, width: imageRef.width, height: imageRef.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        if let context = context {
            let rect = CGRect(0, 0, CGFloat(imageRef.width), CGFloat(imageRef.height))
            context.draw(in: rect, image: imageRef)
            let decompressedImageRef = context.makeImage()
            if let decompressed = decompressedImageRef {
                return UIImage(cgImage: decompressed, scale: scale, orientation: imageOrientation)
            }
        }

        return nil

    }
    
    func cropToBounds(rect: CGRect) -> UIImage? {
        guard let cg = self.cgImage else {
            return nil
        }
        
        guard let cropped = cg.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: cropped, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func maskWithImage(mask: UIImage) -> UIImage? {
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        ctx!.clipToMask(imageRect, mask: mask.cgImage!)
        ctx!.draw(in: imageRect, image: self.cgImage!)
        
        if let resultImage = ctx!.makeImage() {
            return UIImage(cgImage: resultImage)
        }
        else {
            return nil
        }
    }
    
    func resizeImage(size: CGSize) -> UIImage {
        let size = self.size.apply(transform: CGAffineTransform(scaleX: size.width / self.size.width, y: size.height / self.size.height))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}
