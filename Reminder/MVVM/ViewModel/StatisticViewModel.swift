//
//  StatisticViewModel.swift
//  Reminder
//
//  Created by linhnd99 on 08/03/2022.
//

import UIKit

struct StatisticViewModel {
    private var reminderDao = DIContainer.shared.resolve(ReminderDao.self)
    private var colors: [Int] = [0x5A77ED, 0xFF4E4E, 0xEEEEEF]
    
    func color(at index: Int) -> UIColor {
        return UIColor(rgb: colors[index])
    }
    
    func numberOfCompleted() -> Int {
        reminderDao.getAll().filter({ $0.isCompleted }).count
    }
    
    func numberOfPastDeadline() -> Int {
        reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 < Date().timeIntervalSince1970}).count
    }
    
    func numberOfStillOnGoing() -> Int {
        reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 > Date().timeIntervalSince1970}).count
    }
    
    func completedPercent() -> Int {
        let sum = self.numberOfCompleted() + self.numberOfPastDeadline() + self.numberOfStillOnGoing()
        if sum == 0 {
            return 0
        }
        
        return Int(Double(self.numberOfCompleted()) / Double(sum) * 100)
    }
}
