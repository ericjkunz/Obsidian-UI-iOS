//
//  DownloadCache.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit

public protocol Cacheable {
    
    /// An identifier for the cached item
    var identifier: String { get }
    
    /// The URL from which the data should be downloaded, and eventually cached
    var url: NSURL { get }
    
    /// The type of the file being downloaded from the URL.  If nil, uses the path extension from the URL instead.  See Apple's UTType Reference for more details.
    var fileType: CFString? { get }
    
}

private protocol DummySessionDelegate: class {
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?)
}

private class SessionDelegate: NSObject, URLSessionDownloadDelegate {
    
    private weak var delegate: DummySessionDelegate?
    
    private func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        delegate?.URLSession(session: session, task: task, didCompleteWithError: error)
    }
    
    private func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.URLSession(session: session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
    }
    
}

public class DownloadCache<T: Cacheable>: DummySessionDelegate {
    
    // MARK: Types
    
    /// :nodoc:
    public typealias Completion = (item: T) -> ()
    
    /// :nodoc:
    public typealias Failure = (item: T, error: NSError) -> ()
    
    // MARK: Properties
    
    /// The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.
    public let name: String
    
    /// The closure that will be executed on successful item caching.
    public var itemCompletion: Completion?
    
    /// The closure that will be executed when caching fails for an item
    public var itemFailure: Failure?
    
    /// An read-only array representing the current items in the queue
    public var queue: [T] {
        var q: [T] = []
        
        queueMutex.perform {
            q += self.tasks.map { (x: (key: String, value: (task: URLSessionDownloadTask, item: T))) -> (String, T) in
                let key = x.key
                let item = x.value.item
                return (key, item)
            }.values
        }
        
        return q
    }
    
    // MARK: Private Properties
    
    private var directory: String {
        let dir = NSString(string: NSString(string: Directories.cache).appendingPathComponent(UIApplication.shared().bundleIdentifier)).appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch _ {}
        return dir
    }
    
    private let sessionDelegate: SessionDelegate
    private let session: URLSession
    private var queueMutex = MutexPool()
    private var tasks: [ String : (task: URLSessionDownloadTask, item: T) ] = [:]
    
    // MARK: Initialization
    
    /**
     Initializes and returns a newly allocated DownloadCache object with the specified name.
     
     - parameter name: The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.
     - parameter configuration: The NSURLSessionConfiguration to use when instantiating the DownloadCache's internal NSURLSession.
     
     - returns: An initialized DownloadCache object
     
     */
    public init(name: String, configuration: URLSessionConfiguration) {
        self.name = name
        sessionDelegate = SessionDelegate()
        session = Foundation.URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        sessionDelegate.delegate = self
    }
    
    /**
     Initializes and returns a newly allocated DownloadCache object with the specified name.
     
     - parameter name: The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.
     
     - returns: An initialized DownloadCache object
     
     */
    public convenience init(name: String) {
        self.init(name: name, configuration: URLSessionConfiguration.default)
    }
    
    // MARK: File Management
    
    private func path(for item: Cacheable, part: Bool = false) -> String {
        
        var ext = item.url.pathExtension
        
        if let typeIdentifier = item.fileType, let typeExtension = UTTypeCopyPreferredTagWithClass(typeIdentifier, kUTTagClassFilenameExtension)?.takeUnretainedValue() as? String {
            ext = typeExtension
        }
        
        var filename = NSString(string: item.identifier)
        
        if let pathExtension = ext, let filenameWithExtension = filename.appendingPathExtension(pathExtension) {
            filename = filenameWithExtension
        }
        
        if let filenameWithPartExtension = filename.appendingPathExtension("part"), part {
            filename = filenameWithPartExtension
        }
        
        return NSString(string: directory).appendingPathComponent(filename as String)
        
    }
    
    private func exists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    private func task(_ item: Cacheable) -> URLSessionDownloadTask? {
        
        let contentPath = path(for: item)
        let partPath = path(for: item, part: true)
        
        if exists(path: contentPath) {
            return nil
        } else if let partData = NSData(contentsOfFile: partPath), exists(path: partPath) {
            return session.downloadTask(withResumeData: partData as Data)
        } else {
            return session.downloadTask(with: item.url as URL)
        }
        
    }
    
    // MARK: Managing the Cache Queue
    
    /// Resumes any active downloads
    public func resume() {
        queueMutex.perform {
            let running = self.tasks.filter({ (key, val) -> Bool in
                let result = val.task.state == .running
                return result
            })
            if running.isEmpty {
                let stopped = self.tasks.filter({ (key, val) -> Bool in
                    let result = val.task.state == .suspended
                    return result
                })
                
                if let firstTask = stopped.first {
                    let task = firstTask.value.task
                    task.resume()
                }
            }
        }
    }
    
    /// Pauses any active downloads
    public func pause() {
        queueMutex.perform {
            for (_, v) in self.tasks {
                if v.task.state == .running {
                    v.task.suspend()
                }
            }
        }
    }
    
    /**
     Enqueues an item.  Passing an item that has already been enqueued results in a no-op.
     
     - parameter item: The item (conforming to the Cacheable protocol) to enqueue.
     
     */
    public func enqueue(item: T) {
        queueMutex.perform {
            if let task = self.task(item) {
                if self.tasks[item.identifier] == nil {
                    self.tasks[item.identifier] = (task: task, item: item)
                }
            } else {
                DispatchQueue.main.async {
                    self.handleCompletion(of: item, error: nil)
                }
            }
        }
        resume()
    }
    
    /**
     Enqueues an array of items.  Items that have already been enqueued will be skipped.
     
     - parameter items: The array of items (conforming to the Cacheable protocol) to enqueue.
     
     */
    public func enqueue(items: [T]) {
        items.forEach(enqueue)
    }
    
    /**
     Dequeues an item.  Passing an item that is not in the queue results in a no-op.
     
     - parameter item: The item (conforming to the Cacheable protocol) to dequeue.
     
     */
    public func dequeue(item: T) {
        queueMutex.perform {
            if let entry = self.tasks[item.identifier] {
                
                if entry.task.state == .running {
                    let path = self.path(for: item, part: true)
                    entry.task.cancel { (data) -> Void in
                        _ = try? data?.write(to: URL(fileURLWithPath: path), options: .atomic)
                    }
                }
                
                self.tasks.removeValue(forKey: item.identifier)
            }
        }
    }
    
    /**
     Dequeues an array of items.  Items that are not in the queue will be skipped.
     
     - parameter items: The array of items (conforming to the Cacheable protocol) to dequeue.
     
     */
    public func dequeue(items: [T]) {
        items.forEach(dequeue)
    }
    
    /**
     Returns a file URL to the passed item
     
     - parameter item: The item to look up
     
     - returns:  An NSURL pointing to the cached item, or nil if it has not yet been cached
     
     */
    public func get(item: T) -> NSURL? {
        let filePath = path(for: item, part: false)
        if exists(path: filePath) {
            return NSURL(fileURLWithPath: filePath)
        } else {
            return nil
        }
    }
    
    // MARK: DummySessionDelegate
    
    private func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        queueMutex.perform {
            
            let matching = self.tasks.filter({ (key, val) -> Bool in
                return val.task == downloadTask
            })
            
            if !matching.isEmpty {
                if let path = location.path {
                    let firstItem = matching[0].value.item
                    let toPath = self.path(for: firstItem)
                    do {
                        try FileManager.default.moveItem(atPath: path, toPath: toPath)
                    } catch _ {
                    }
                }
            }
            
        }
        
        do {
            try FileManager.default.removeItem(at: location as URL)
        } catch _ {
        }
        
    }
    
    private func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        
        queueMutex.perform {
            self.tasks = self.tasks.filter(includeElement: { (key, val) -> Bool in
                let match = val.task == task
                
                if match {
                    DispatchQueue.main.async {
                        self.handleCompletion(of: val.item, error: error)
                    }
                }
                
                return !match
            })
        }
        
        resume()
        
    }
    
    // MARK: Notifications
    
    private func handleCompletion(of item: T, error: NSError?) {
        if let e = error {
            self.itemFailure?(item: item, error: e)
        } else {
            self.itemCompletion?(item: item)
        }
    }
    
}
