//
//  ImageDownloader.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

public final class ImageDownloader {

    // MARK: Public Properties

    /// A definition of the closure called when an image download operation completes
    public typealias Completion = (image: UIImage?, error: NSError?) -> ()

    /// The shared ImageDownloader
    public static let sharedInstance = ImageDownloader()

    // MARK: Private Properties

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
        }()

    private let cache = MemoryCache<NSURL, UIImage>(identifier: Constants.ImageCacheName)

    // MARK: Initialization

    private init() {

    }

    // MARK: Image Downloading

    /**
    Downloads and caches an image at the passed URL

    - parameter url: The URL of the image to download
    - parameter completion: The closure to execute when the download completes (or fails)

    - returns: An ImageDownloadTask that can be used to cancel the download operation

    */
    public func download(url: NSURL, completion: Completion?) -> ImageDownloadTask? {


        if let image = self.cache[url] {
            MainQueue.async {
                completion?(image: image, error: nil)
            }
            return nil
        }

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let e = error {
                MainQueue.async {
                    completion?(image: nil, error: e)
                }
            } else if data != nil {
                let theData = data!
                let image = UIImage(data: theData)?.decodedImage()
                self.cache[url] = image
                MainQueue.async {
                    completion?(image: image, error: nil)
                }
            }
        })

        task.resume()

        return ImageDownloadTask(task: task)

    }

}

public struct ImageDownloadTask {

    private let task: URLSessionDataTask

    /// Cancels the task
    public func cancel() {
        task.cancel()
    }

}
