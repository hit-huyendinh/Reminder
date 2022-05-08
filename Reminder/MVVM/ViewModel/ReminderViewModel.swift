//
//  ReminderViewModel.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation

struct ReminderViewModel {
    var reminder: Reminder
    private var reminderDao = DIContainer.shared.resolve(ReminderDao.self)
    
    init(reminder: Reminder) {
        self.reminder = reminder
    }
    
    func name() -> String {
        return reminder.name
    }
    
    func subtitleString() -> String {
        var result = targetTimeFullString()
        if reminder.isCompleted {
            return result
        }
        
        if reminder.remindingRepeat.rawValue != 0  {
            result = "\(result), \(reminder.remindingRepeat.string)"
        }
        
        if let endRepeatString = reminder.remindingEndRepeat?.string {
            result = "\(result), \(endRepeatString)"
        }
        
        return result
    }

    func targetDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: reminder.targetTime)
    }

    func targetTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: reminder.targetTime)
    }

    func reminderTimeString() -> String {
        return reminder.remindingTime.string
    }

    func remindingRepeatString() -> String {
        return reminder.remindingRepeat.string
    }

    func remindingEndRepeatString() -> String {
        reminder.remindingEndRepeat?.string ?? "Forever"
    }
    
    func isLater() -> Bool {
        return reminder.targetTime <= Date() && !reminder.isCompleted
    }
    
    func isCompleted() -> Bool {
        return reminder.isCompleted
    }
    
    // MARK: - Helper
    private func targetTimeFullString() -> String {
        let now = Date()
        if reminder.targetTime.year == now.year && reminder.targetTime.month == now.month && reminder.targetTime.day == now.day {
            return "Today, \(reminder.targetTime.hour):\(reminder.targetTime.minute)"
        }
        
        let tomorrow = Date().tomorrow
        if reminder.targetTime.year == tomorrow.year && reminder.targetTime.month == tomorrow.month && reminder.targetTime.day == tomorrow.day {
            return "Tomorrow, \(reminder.targetTime.hour):\(reminder.targetTime.minute)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm"
        return dateFormatter.string(from: reminder.targetTime)
    }
    
    // MARK: - Dao
    func saveToDB() {
        reminderDao.addAndUpdate(reminder: reminder)
    }
    
    func deleteInDB() {
        reminderDao.remove(reminder: reminder)
    }
}
