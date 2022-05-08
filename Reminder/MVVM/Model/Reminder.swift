//
//  Reminder.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

class Reminder {
    var id: String = UUID().uuidString
    var name: String
    var createdTime: Date = Date()
    var targetTime: Date = Date()
    var remindingTime: RemindingTime = .never
    var remindingRepeat: ReminderRepeat = .never
    var remindingEndRepeat: ReminderEndRepeat? = nil
    var isCompleted: Bool = false
    var categoryId: String
    var requestNotificationId: String?
    
    init(name: String, categoryId: String) {
        self.name = name
        self.categoryId = categoryId
    }
    
    init(rlmObject: RLMReminder) {
        self.id = rlmObject.id
        self.name = rlmObject.name
        self.createdTime = Date(timeIntervalSince1970: rlmObject.createdTime)
        self.targetTime = Date(timeIntervalSince1970: rlmObject.targetTime)
        self.remindingTime = RemindingTime(rawValue: rlmObject.remindingTime)
        self.remindingRepeat = ReminderRepeat(rawValue: rlmObject.remindingRepeat)!
        self.remindingEndRepeat = rlmObject.remindingEndRepeat != -2 ? ReminderEndRepeat(rawValue: rlmObject.remindingEndRepeat) : nil
        self.isCompleted = rlmObject.isCompleted
        self.categoryId = rlmObject.categoryId
        self.requestNotificationId = rlmObject.requestNotificationId
    }
    
    init(cdObject: CDReminder) {
        self.id = cdObject.id
        self.name = cdObject.name
        self.createdTime = Date(timeIntervalSince1970: cdObject.createdTime)
        self.targetTime = Date(timeIntervalSince1970: cdObject.targetTime)
        self.remindingTime = RemindingTime(rawValue: cdObject.remindingTime)
        self.remindingRepeat = ReminderRepeat(rawValue: cdObject.remindingRepeat)!
        if let endRepeat = cdObject.remindingEndRepeat {
            self.remindingEndRepeat = ReminderEndRepeat(rawValue: endRepeat)
        } else {
            self.remindingEndRepeat = nil
        }
        self.isCompleted = cdObject.isCompleted
        self.categoryId = cdObject.categoryId
        self.requestNotificationId = cdObject.requestNotificationId
    }
    
    func rlmObject() -> RLMReminder {
        let rlmObject = RLMReminder()
        rlmObject.id = self.id
        rlmObject.name = self.name
        rlmObject.createdTime = self.createdTime.timeIntervalSince1970
        rlmObject.targetTime = self.targetTime.timeIntervalSince1970
        rlmObject.remindingTime = self.remindingTime.rawValue
        rlmObject.remindingRepeat = self.remindingRepeat.rawValue
        rlmObject.remindingEndRepeat = self.remindingEndRepeat?.rawValue ?? -2
        rlmObject.isCompleted = self.isCompleted
        rlmObject.categoryId = self.categoryId
        rlmObject.requestNotificationId = self.requestNotificationId
        return rlmObject
    }
    
    func cdObject() -> CDReminder {
        return CDReminder(id: self.id,
                          name: self.name,
                          createdTime: self.createdTime.timeIntervalSince1970,
                          targetTime: self.targetTime.timeIntervalSince1970,
                          remindingTime: self.remindingTime.rawValue,
                          remindingRepeat: self.remindingRepeat.rawValue,
                          remindingEndRepeat: self.remindingEndRepeat?.rawValue,
                          isCompleted: self.isCompleted, categoryId: self.categoryId,
                          requestNotificationId: self.requestNotificationId)
    }
}
