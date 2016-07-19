//
//  FeatureDetection.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/20/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AVFoundation

public class FeatureDetection {

    /**
    Detects faces.

    - returns: An array of detected faces.

    */
    public func detectFacesInImage(image: CIImage) -> [CIFaceFeature] {
        let features = detectFeaturesInImage(image)
        var faces = [CIFaceFeature]()
        for feature in features {
            if let face = feature as? CIFaceFeature {
                faces.append(face)
            }
        }

        return faces
    }

    /**
    Detects faces.

    - returns: An array of detected faces.

    */
    public func detectFacesInImage(image: UIImage) -> [CIFaceFeature] {
        return detectFacesInImage(image.CIImage!)
    }

    /**
    Detects faces, rectangles, QR codes, and text.

    - returns: An array of detected features.

    */
    public func detectFeaturesInImage(image: CIImage) -> [CIFeature] {
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : true])
        return detector.featuresInImage(image)
    }

    /**
    Detects faces, rectangles, QR codes, and text.

    - returns: An array of detected features.

    */
    public func detectFeaturesInImage(image: UIImage) -> [CIFeature] {
        return detectFeaturesInImage(image.CIImage!)
    }

    /**
    Transforms the frames of CIFeature objects into another frame.
    Can be used to get feature frames for a camera preview as the device's camera image usually originates
    differently and is at a different scale than is previewed.

    If you are using face detection in a CMSampleBufferDelegate method like
    - captureOutput:didOutputSampleBuffer:fromConnection: , you can get the clean aperture as follows.

        let description: CMFormatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(description, Boolean(0))

    - parameter features: An Array of CIFeature.
    - parameter previewLayer: The layer that view frames will be translated to.
    - parameter cleanAperture: The clean aperture is a rectangle that defines the portion of the encoded pixel dimensions that represents image data valid for display.
    - parameter mirrored: Is the video from the camera horizontally flipped for the preview.

    */
    public func rectsForFeatures(features: [CIFeature], previewLayer: AVCaptureVideoPreviewLayer, cleanAperture: CGRect, mirrored: Bool) -> [CGRect] {
        var featureRects = [CGRect]()
        for feature in features {
            featureRects.append(rectForFeature(feature, previewLayer: previewLayer, cleanAperture: cleanAperture, mirrored: mirrored))
        }
        return featureRects
    }

    /**
    Transforms the frames of CIFeature objects into another frame.
    Can be used to get feature frames for a camera preview as the device's camera image usually originates
    differently and is at a different scale than is previewed.

    If you are using face detection in a CMSampleBufferDelegate method like
    - captureOutput:didOutputSampleBuffer:fromConnection: , you can get the clean aperture as follows.

        let description: CMFormatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(description, Boolean(0))

    - parameter feature: A CIFeature.
    - parameter previewLayer: The layer that view frames will be translated to.
    - parameter cleanAperture: The clean aperture is a rectangle that defines the portion of the encoded pixel dimensions that represents image data valid for display.
    - parameter mirrored: Is the video from the camera horizontally flipped for the preview.

    */
    public func rectForFeature(feature: CIFeature, previewLayer: AVCaptureVideoPreviewLayer, cleanAperture: CGRect, mirrored: Bool) -> CGRect {
        return locationOfFaceInView(feature.bounds, gravity: previewLayer.videoGravity, previewFrame: previewLayer.frame, cleanAperture: cleanAperture, mirrored: mirrored)
    }

    private func locationOfFaceInView(featureBounds: CGRect, gravity: String, previewFrame: CGRect, cleanAperture: CGRect, mirrored: Bool) -> CGRect {
        let parentFrameSize = previewFrame.size
        let cleanApertureSize = cleanAperture.size
        // find where the video box is positioned within the preview layer based on the video size and gravity
        let previewBox = videoPreviewBox(gravity: gravity, frameSize: parentFrameSize, apertureSize: cleanApertureSize)

        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        var faceRect = featureBounds

        // flip preview width and height
        var temp = faceRect.size.width
        faceRect.size.width = faceRect.size.height
        faceRect.size.height = temp
        temp = faceRect.origin.x
        faceRect.origin.x = faceRect.origin.y
        faceRect.origin.y = temp
        // scale coordinates so they fit in the preview box, which may be scaled
        let widthScaleBy = previewBox.size.width / cleanApertureSize.height
        let heightScaleBy = previewBox.size.height / cleanApertureSize.width
        faceRect.size.width *= widthScaleBy
        faceRect.size.height *= heightScaleBy
        faceRect.origin.x *= widthScaleBy
        faceRect.origin.y *= heightScaleBy

        if mirrored {
            faceRect = faceRect.offsetBy(dx: previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), dy: previewBox.origin.y)
        } else {
            faceRect = faceRect.offsetBy(dx: previewBox.origin.x, dy: previewBox.origin.y)
        }

        return faceRect
    }

    private func videoPreviewBox(gravity: String, frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height

        var size = CGSize.zero
        if gravity == AVLayerVideoGravityResizeAspectFill {
            if viewRatio > apertureRatio {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            } else {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            }
        } else if gravity == AVLayerVideoGravityResizeAspect {
            if viewRatio > apertureRatio {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            } else {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            }
        } else if gravity == AVLayerVideoGravityResize {
            size.width = frameSize.width
            size.height = frameSize.height
        }

        var videoBox = CGRect.zero
        videoBox.size = size
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2
        }

        if size.height < frameSize.height {
            videoBox.origin.y = (frameSize.height - size.height) / 2
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2
        }

        return videoBox
    }

}
