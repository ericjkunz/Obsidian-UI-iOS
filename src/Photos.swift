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
    
    private class func performChanges(changeBlock: dispatch_block_t, completionHandler: ((Bool, NSError?) -> Void)!) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges(changeBlock, completionHandler: completionHandler)
    }
    
    private class func performChanges(changeBlock: dispatch_block_t) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges(changeBlock, completionHandler: nil)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter completion: called after image is saved
     
     */
    public class func saveImage(image: UIImage, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of an image to be saved
     - parameter completion: Called after the image is saved
     
     */
    public class func saveImage(URL: NSURL, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(URL)
            }, completionHandler: completion)
    }
    
    private class func createAssetCollection(name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
        var alreadyExists = false
        for i in 0 ..< fetchResult.count += 1 {
            if let collection = fetchResult[i] as? PHAssetCollection {
                if collection.localizedTitle == name {
                    alreadyExists = true
                    return collection
                }
            }
        }
        
        var assetCollection: PHAssetCollection?
        if !alreadyExists {
            Photos.performChanges({ () -> Void in
                PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(name)
                
                }, completionHandler: { (success, error) -> Void in
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([name], options: nil)
                    assetCollection =  collectionFetchResult.firstObject as? PHAssetCollection
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
        let assetCollection = createAssetCollection(albumName)
        
        Photos.performChanges({ () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection!)
            let enumeration: NSArray = [assetPlaceholder!]
            albumRequest!.addAssets(enumeration)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter ocmpletion: Called after the video is saved
     
     */
    public class func saveVideo(URL: NSURL, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(URL)
            }, completionHandler: completion)
    }
    
    /**
     Saves a video to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter albumName: The name of the album to save to
     
     */
    public class func saveVideoToAlbum(URL: NSURL, albumName: String, completion: Completion) {
        let assetCollection = Photos.createAssetCollection(albumName)
        
        Photos.performChanges({ () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(URL)
            let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection!)
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
        
        guard let lastAsset = fetchResult.lastObject as? PHAsset else {
            completion?(nil)
            return
        }
        
        PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: size, contentMode: contentMode, options: nil) { (image: UIImage?, dictionary: [NSObject : AnyObject]?) -> Void in
            completion?(image)
        }
        
    }
    
}
