//
//  Logger.swift
//  Alfredo
//
//  Created by Nick Lee on 9/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public struct Logger {

    // MARK: Properties

    /// The date formatter used by the logger
    public static var dateFormatter: NSDateFormatter = {
        let defaultDateFormatter = NSDateFormatter()
        defaultDateFormatter.locale = NSLocale.currentLocale()
        defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return defaultDateFormatter
        }()

    /// Whether or not the logger should print the date of the call
    public static var showDate = true

    /// Whether or not the logger should print the log level associated with the call
    public static var showLogLevel = true

    /// Whether or not the logger should print the name of the thread on which the logger was called
    public static var showThreadName = false

    /// Whether or not the logger should print the name of the calling function
    public static var showFileName = true

    /// Whether or not the logger should print the line number of the parent call
    public static var showLineNumber = true

    /// Whether or not the logger should print the name of the calling function
    public static var showFunctionName = true

    // MARK: Types

    internal enum LogLevel: Int, Comparable, CustomStringConvertible {

        case Verbose
        case Debug
        case Info
        case Warning
        case Error
        case Severe

        internal var description: String {
            switch self {
            case .Verbose:
                return "Verbose"
            case .Debug:
                return "Debug"
            case .Info:
                return "Info"
            case .Warning:
                return "Warning"
            case .Error:
                return "Error"
            case .Severe:
                return "Severe"
            }
        }

    }

    // MARK: Internal Properties

    internal static let sharedInstance = Logger()

    // MARK: Logging

    /// Log the passed string at the verbose level
    public static func verbose(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Verbose, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the debug level
    public static func debug(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Debug, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the info level
    public static func info(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Info, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the warning level
    public static func warning(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Warning, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the error level
    public static func error(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Error, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the severe level
    public static func severe(@autoclosure closure: () -> String?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        log(.Severe, date: NSDate(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    internal static func log(level: LogLevel, date: NSDate, logMessage: String?, functionName: String, fileName: String, lineNumber: Int) {


        let threadName = "[" + (NSThread.isMainThread() ? "main" : (NSThread.currentThread().name != "" ? (NSThread.currentThread().name ?? "Unknown Thread") : String(format:"%p", NSThread.currentThread()))) + "] "

        BackgroundQueue.async {

            var details = ""

            if self.showDate {
                details += self.dateFormatter.stringFromDate(date) + " "
            }

            if self.showLogLevel {
                details += "[\(level)] "
            }

            if self.showThreadName {
                details += threadName
            }

            if self.showFileName {
                details += "[" + NSString(string: fileName).lastPathComponent + (self.showLineNumber ? ":" + String(lineNumber) : "") + "] "
            } else if self.showLineNumber {
                details += "[" + String(lineNumber) + "] "
            }

            if self.showFunctionName {
                details += "\(functionName) > "
            }

            if let message = logMessage {
                details += message
            }

            MainQueue.async {
                Swift.print(details)
            }

        }

    }

}

internal func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
