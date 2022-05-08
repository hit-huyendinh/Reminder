//
//  URLExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

extension URL {
    var params: [String:Any] {
        guard let query = self.query else { return [:] }
        let paramsComponent = query.components(separatedBy: "&")

        var paramsResult = [String:Any]()
        paramsComponent.forEach { (item) in
            let components = item.components(separatedBy: "=")
            let key = components[0]
            let value = components[1]

            paramsResult[key] = value
        }

        return paramsResult
    }
    
    var creationDate: Date? {
        return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
    }
    
    func isVideo() -> Bool {
        if self.pathExtension.lowercased() == "mp4" || self.pathExtension.lowercased() == "flv" || self.pathExtension.lowercased() == "avi" || self.pathExtension.lowercased() == "mpg" || self.pathExtension.lowercased() == "mov" {
            return true
        }
        return false
    }
}
