//
//  FileManagerExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

extension FileManager {
    static func profileImageURL() -> URL {
        return self.documentURL().appendingPathComponent("profileImage.png")
    }
}

extension FileManager {
    static func getSize(path: String) -> UInt64 {
        if let attribute = try? FileManager.default.attributesOfItem(atPath: path) {
            return attribute[FileAttributeKey.size] as! UInt64
        }

        return 0
    }
}

extension FileManager {
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }
    
    static func temporaryPath() -> String {
        return NSTemporaryDirectory()
    }

    static func documentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    static func createDirIfNeeded(path: String) {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)

        if FileManager.default.fileExists(atPath: path, isDirectory: pointer) == false ||
            isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
    }
}
