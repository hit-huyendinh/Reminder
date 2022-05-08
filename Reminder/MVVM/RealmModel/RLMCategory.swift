//
//  RLMCategory.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation
import RealmSwift

class RLMCategory: Object {
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var iconName: String!
    @objc dynamic var color: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["id"]
    }
}
