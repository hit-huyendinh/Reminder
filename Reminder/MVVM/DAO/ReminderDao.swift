//
//  ReminderDao.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation
import UserNotifications

protocol ReminderDao {
    func addAndUpdate(reminder: Reminder)
    func getAll() -> [Reminder]
    func getReminders(categoryId: String) -> [Reminder]
    func getReminders(categoryId: String, date: Date) -> [Reminder]
    func getReminder(id: String) -> Reminder?
    func remove(reminder: Reminder)
}

final class ReminderDaoImpl: RealmDao, ReminderDao {
    private var notificationManager = DIContainer.shared.resolve(NotificationManager.self)
    
    func addAndUpdate(reminder: Reminder) {
        let oldReminder = self.getReminder(id: reminder.id)
        if let oldId = oldReminder?.requestNotificationId {
            self.notificationManager.cancelRequest(requestId: oldId)
        }
        
        if let newId = self.notificationManager.scheduleNotification(reminder: reminder) {
            reminder.requestNotificationId = newId
        }
        
        try? self.addObjectAndUpdate(reminder.rlmObject())
    }
    
    func getAll() -> [Reminder] {
        guard let result = try? self.objects(type: RLMReminder.self) else {
            return []
        }
        
        return result.map({ Reminder(rlmObject: $0) }).sorted { lhs, rhs in
            let lhsInt = lhs.isCompleted ? 1 : 0
            let rhsInt = rhs.isCompleted ? 1 : 0
            return lhsInt < rhsInt
        }
    }
    
    func getReminders(categoryId: String) -> [Reminder] {
        return self.getAll().filter({$0.categoryId == categoryId}).sorted { lhs, rhs in
            let lhsInt = lhs.isCompleted ? 1 : 0
            let rhsInt = rhs.isCompleted ? 1 : 0
            return lhsInt < rhsInt
        }
    }
    
    func getReminders(categoryId: String, date: Date) -> [Reminder] {
        return self.getAll().filter({$0.categoryId == categoryId && $0.targetTime.compare(date: date, format: "yyyy/MM/dd") == 0}).sorted { lhs, rhs in
            let lhsInt = lhs.isCompleted ? 1 : 0
            let rhsInt = rhs.isCompleted ? 1 : 0
            return lhsInt < rhsInt
        }
    }
    
    func getReminder(id: String) -> Reminder? {
        if let rlmObject = try? self.objectWithPrimaryKey(type: RLMReminder.self, key: id) {
            return Reminder(rlmObject: rlmObject)
        }
        
        return nil
    }
    
    func remove(reminder: Reminder) {
        if let rlmObject = try? self.objectWithPrimaryKey(type: RLMReminder.self, key: reminder.id) {
            try? self.deleteObjects([rlmObject])
        }
    }
}
