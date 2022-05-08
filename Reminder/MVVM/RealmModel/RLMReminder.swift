//
//  RLMReminder.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import UIKit
import RealmSwift

class RLMReminder: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String!
    @objc dynamic var createdTime: Double = 0
    @objc dynamic var targetTime: Double = 0
    @objc dynamic var remindingTime: Double = 0
    @objc dynamic var remindingRepeat: Int = 0
    @objc dynamic var remindingEndRepeat: Double = 0
    @objc dynamic var isCompleted: Bool = false
    @objc dynamic var categoryId: String!
    @objc dynamic var requestNotificationId: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["id"]
    }
}
