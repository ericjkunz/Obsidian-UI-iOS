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
    
    enum PhotosError: ErrorProtocol {
        case InvalidURL(message: String)
    }
    
    public typealias Completion = ((Bool, NSError?) -> Void)?
    public typealias ImageCompletion = ((UIImage?) -> Void)
    public typealias ChangeBlock = () -> Void
    
    private class func performChanges(_ changeBlock: ChangeBlock, completionHandler: Completion = nil) {
        PHPhotoLibrary.shared().performChanges(changeBlock, completionHandler: completionHandler)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter completion: called after image is saved
     
     */
    public class func saveImageToPhotosLibrary(_ image: UIImage, completion: Completion = nil) {
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter url: The url of an image to be saved
     - parameter completion: Called after the image is saved
     
     */
    public class func saveImageToPhotosLibrary(from url: URL, completion: Completion = nil) throws {
        if let path = url.path {
            if !FileManager.default.fileExists(atPath: path) {
                throw PhotosError.InvalidURL(message: "\(#function) - No file exists at URL: \(url)")
            }
        }
        
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            }, completionHandler: completion)
    }
    
    private class func createAssetCollection(named name: String, completion: (collection: PHAssetCollection?) -> Void) {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
        for i in 0..<fetchResult.count {
            let collection = fetchResult[i]
            if collection.localizedTitle == name {
                completion(collection: collection); return
            }
        }
        
        Photos.performChanges({ () -> Void in
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            
            }, completionHandler: { (success, error) -> Void in
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [name], options: nil)
                if let match = collectionFetchResult.firstObject {
                    completion(collection: match)
                }
        })
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter albumName: The name of the album to save to
     - parameter completion: Called after the image is saved
     
     */
    public class func saveImage(_ image: UIImage, toAlbum albumName: String, completion: Completion) {
        createAssetCollection(named: albumName) { (collection) in
            
            Photos.performChanges({
                
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetRequest.placeholderForCreatedAsset
                if let collection = collection {
                    let albumRequest = PHAssetCollectionChangeRequest(for: collection)
                    let enumeration: NSArray = [assetPlaceholder!]
                    albumRequest!.addAssets(enumeration)
                } else {
                    let error = NSError(domain: "uh, a domain", code: 0, userInfo: nil)
                    completion?(false, error) // eric. test this out
                }
                
                }, completionHandler: completion)
        }
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter ocmpletion: Called after the video is saved
     
     */
    public class func saveVideoToPhotosLibrary(from url: URL, completion: Completion = nil) throws {
        if let path = url.path {
            if !FileManager.default.fileExists(atPath: path) {
                throw PhotosError.InvalidURL(message: "\(#function) - No file exists at URL: \(url)")
            }
        }
        
        Photos.performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: completion)
    }
    
    /**
     Saves a video to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter albumName: The name of the album to save to
     
     */
    public class func saveVideoToAlbum(from url: URL, albumName: String, completion: Completion) throws {
        if let path = url.path {
            if !FileManager.default.fileExists(atPath: path) {
                throw PhotosError.InvalidURL(message: "\(#function) - No file exists at URL: \(url)")
            }
        }
        
        Photos.createAssetCollection(named: albumName) { (collection) in
            if let collection = collection {
                Photos.performChanges({ () -> Void in
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
                    let albumRequest = PHAssetCollectionChangeRequest(for: collection)
                    let enumeration = [assetPlaceholder!]
                    albumRequest?.addAssets(enumeration)
                    
                    }, completionHandler: completion)
            }
            else {
                completion?(false, NSError())
            }
        }
        
    }
    
    /**
     Gets the most recently created asset in the photo library
     
     - parameter size: The size the image will be returned in
     - parameter contentMode: How the image will fit into the size parameter
     
     */
    public class func latestImage(size: CGSize, contentMode: PHImageContentMode, requestOptions: PHImageRequestOptions = defaultOptions(), completion: ImageCompletion) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [SortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        guard let lastAsset = fetchResult.lastObject else {
            completion(nil)
            return
        }
        
        PHImageManager.default().requestImage(for: lastAsset, targetSize: size, contentMode: contentMode, options: nil) { (image: UIImage?, dictionary: [NSObject : AnyObject]?) -> Void in
            completion(image)
        }
    }
    
    private func defaultOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        return options
    }
}
