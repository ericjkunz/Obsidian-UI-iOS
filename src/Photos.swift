//
//  Photos.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/17/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import Photos

/**
 This class manages photo library assets.
 Adding and retreiving photos happens on an arbitrary serial queue. Dispatch calls to the maine queue to update the app's UI as a result of a change.
 */
public class Photos {
    
    public typealias Completion = ((Bool, NSError?) -> Void)?
    public typealias ImageCompletion = ((UIImage?) -> Void)?
    public typealias ChangeBlock = () -> Void
    
    private class func performChanges(_ changeBlock: ChangeBlock, completionHandler: Completion = nil) {
        PHPhotoLibrary.shared().performChanges(changeBlock, completionHandler: completionHandler)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter completion: called after image is saved
     
     */
    public class func saveImage(image: UIImage, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of an image to be saved
     - parameter completion: Called after the image is saved
     
     */
    public class func saveImage(URL: URL, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL)
            }, completionHandler: completion)
    }
    
    private class func createAssetCollection(named name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
        var alreadyExists = false
        for i in 0..<fetchResult.count {
            let collection = fetchResult[i]
            if collection.localizedTitle == name {
                alreadyExists = true
                return collection
            }
        }
        
        var assetCollection: PHAssetCollection?
        if !alreadyExists {
            Photos.performChanges({ () -> Void in
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                
                }, completionHandler: { (success, error) -> Void in
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [name], options: nil)
                    assetCollection =  collectionFetchResult.firstObject
            })
        }
        
        return assetCollection
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter albumName: The name of the album to save to
     - parameter completion: Called after the image is saved
     
     */
    public class func saveImageToAlbum(image: UIImage, albumName: String, completion: Completion) {
        let assetCollection = createAssetCollection(named: albumName)
        
        Photos.performChanges({ () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(for: assetCollection!)
            let enumeration: NSArray = [assetPlaceholder!]
            albumRequest!.addAssets(enumeration)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter ocmpletion: Called after the video is saved
     
     */
    public class func saveVideo(URL: URL, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL)
            }, completionHandler: completion)
    }
    
    /**
     Saves a video to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter albumName: The name of the album to save to
     
     */
    public class func saveVideoToAlbum(URL: URL, albumName: String, completion: Completion) {
        let assetCollection = Photos.createAssetCollection(named: albumName)
        
        Photos.performChanges({ () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL)
            let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(for: assetCollection!)
            let enumeration: NSArray = [assetPlaceholder!]
            albumRequest?.addAssets(enumeration)
            
            }, completionHandler: completion)
    }
    
    /**
     Gets the most recently created asset in the photo library
     
     - parameter size: The size the image will be returned in
     - parameter contentMode: How the image will fit into the size parameter
     
     */
    public class func latestAsset(size: CGSize, contentMode: PHImageContentMode, completion: ImageCompletion) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [SortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        guard let lastAsset = fetchResult.lastObject else {
            completion?(nil)
            return
        }
        
        PHImageManager.default().requestImage(for: lastAsset, targetSize: size, contentMode: contentMode, options: nil) { (image: UIImage?, dictionary: [NSObject : AnyObject]?) -> Void in
            completion?(image)
        }
        
    }
    
}
