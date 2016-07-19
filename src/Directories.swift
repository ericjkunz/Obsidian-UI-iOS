//
//  Directories.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public struct Directories {

    private static func findSandboxedDirectory(in directory: FileManager.SearchPathDirectory) -> String! {
        let candidates = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        return candidates.first
    }

    /// The running application's documents directory
    public static let documents: String! = Directories.findSandboxedDirectory(in: .documentDirectory)

    /// The running application's cache directory
    public static let cache: String! = Directories.findSandboxedDirectory(in: .cachesDirectory)

    /// The running application's temporary directory
    public static let temporary: String! = NSTemporaryDirectory()

}
