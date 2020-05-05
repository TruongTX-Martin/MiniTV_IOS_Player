//
//  DLog.swift
//  WebRTC-SFSafariViewController-Demo
//
//  Created by Michael Nguyen on 4/13/20.
//  Copyright © 2020 Mini School. All rights reserved.
//
import Foundation

public enum DLog {
    
    static var formatter: DateFormatter?
    /// Result is zero overhead for release builds.
    public static func printLog(_ message: Any, pathFile: String = #file, function: String = #function, line: Int = #line) {
        
        let className = URL(fileURLWithPath: pathFile).deletingPathExtension().lastPathComponent
        
        let log = "\(timestamp) \(className).\(function) _line \(line): \(message)"
        assert(debugPrint(log))
    }
    
    private static func debugPrint(_ message: Any) -> Bool {
        print(message)
        return true
    }
    
    /// Creates a timestamp used as part of the temporary logging in the debug area.
    static private var timestamp: String {
        
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "dd/MM/yyyy HH:mm:ss"
        }
        
        let date = Date()
        return formatter!.string(from: date)
    }
}
