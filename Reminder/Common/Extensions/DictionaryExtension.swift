//
//  DictionaryExtension.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//
import Foundation

extension Dictionary {
    func jsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return ""
        }
        
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
}
