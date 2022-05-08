//
//  ReminderByCategoryViewModel.swift
//  Reminder
//
//  Created by linhnd99 on 09/03/2022.
//

import UIKit

struct ReminderByCategoryViewModel {
    private let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
    private let section = ["Postpone", "Today", "Tomorrow", "Upcoming", "No date"]
    var category: Category
    var isShowCompleted: Bool
    
    init(category: Category) {
        self.category = category
        self.isShowCompleted = false
    }
    
    func categoryName() -> String {
        return category.name
    }
    
    func categoryImage() -> UIImage? {
        return UIImage(named: category.iconName)
    }
    
    func isEmpty() -> Bool {
        return reminderPostpone().count + reminderToday().count + reminderTomorrow().count + reminderUpcomming().count + reminderNoDate().count == 0
    }
    
    func reminder(at index: Int, in section: Int) -> ReminderViewModel {
        if section == 0 {
            return ReminderViewModel(reminder: reminderPostpone()[index])
        } else if section == 1 {
            return ReminderViewModel(reminder: reminderToday()[index])
        } else if section == 2 {
            return ReminderViewModel(reminder: reminderTomorrow()[index])
        } else if section == 3 {
            return ReminderViewModel(reminder: reminderUpcomming()[index])
        }
        
        return ReminderViewModel(reminder: reminderNoDate()[index])
    }
    
    func numberOfReminders(in section: Int) -> Int {
        if section == 0 {
            return reminderPostpone().count
        } else if section == 1 {
            return reminderToday().count
        } else if section == 2 {
            return reminderTomorrow().count
        } else if section == 3 {
            return reminderUpcomming().count
        }
        
        return reminderNoDate().count
    }
    
    func titleSection(index: Int) -> String {
        return section[index]
    }
    
    func numberOfSection() -> Int {
        return section.count
    }
    
    func updateCompleted(_ value: Bool, reminder: Reminder) {
        reminder.isCompleted = value
        reminderDao.addAndUpdate(reminder: reminder)
    }
    
    func removeThisCategory() {
        reminderDao.getAll().forEach { reminder in
            if reminder.categoryId == self.category.id {
                reminderDao.remove(reminder: reminder)
            }
        }
        
        let categoryDao = DIContainer.shared.resolve(CategoryDao.self)
        categoryDao.remove(category: category)
    }
    
    // MARK: - Private
    private func reminderPostpone() -> [Reminder] {
        return reminderDao.getAll()
            .filter({$0.categoryId == category.id})
            .filter({$0.targetTime.timeIntervalSince1970 < Date().timeIntervalSince1970 && (!$0.isCompleted || self.isShowCompleted)})
    }
    
    private func reminderToday() -> [Reminder] {
        return reminderDao.getAll()
            .filter({$0.categoryId == category.id})
            .filter({$0.targetTime.isInToday})
            .sorted(by: {($0.isCompleted ? 1 : 0) < ($1.isCompleted ? 1 : 0)})
    }
    
    private func reminderTomorrow() -> [Reminder] {
        return reminderDao.getAll()
            .filter({$0.categoryId == category.id})
            .filter({$0.targetTime.isInTomorrow})
            .sorted(by: {($0.isCompleted ? 1 : 0) < ($1.isCompleted ? 1 : 0)})
    }
    
    private func reminderUpcomming() -> [Reminder] {
        return reminderDao.getAll()
            .filter({$0.categoryId == category.id})
            .filter({!$0.targetTime.isInTomorrow && !$0.targetTime.isInToday && $0.targetTime.timeIntervalSince1970 > Date().timeIntervalSince1970})
            .sorted(by: {($0.isCompleted ? 1 : 0) < ($1.isCompleted ? 1 : 0)})
    }
    
    private func reminderNoDate() -> [Reminder] {
        return []
    }
}
