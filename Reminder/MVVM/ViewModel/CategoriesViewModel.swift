//
//  CategoriesViewModel.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 24/02/2022.
//

import Foundation

struct CategoriesViewModel {
    var categories: [Category]!
    var date: Date?
    var nameFiltered: String?

    init(date: Date? = nil) {
        self.date = date
        self.refresh()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func categoryAt(index: Int) -> CategoryViewModel {
        return CategoryViewModel(category: categories[index], date: date, nameFiltered: nameFiltered)
    }
    
    func setIsCompleted(_ isCompleted: Bool, for reminder: Reminder) {
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        reminder.isCompleted = isCompleted
        reminderDao.addAndUpdate(reminder: reminder)
    }
    
    mutating func refresh() {
        let categoryDao = DIContainer.shared.resolve(CategoryDao.self)
        categories = categoryDao.getAll()
    }

    func numberOfTasks() -> Int {
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        var counter = 0
        categories.forEach { category in
            if let date = self.date {
                counter += reminderDao.getReminders(categoryId: category.id, date: date).count
            } else {
                counter += reminderDao.getReminders(categoryId: category.id).count
            }
        }

        return counter
    }

    mutating func deleteTask(categoryIndex: Int, taskIndex: Int) {
        let reminderViewModel = self.categoryAt(index: categoryIndex).reminderAt(index: taskIndex)
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        reminderDao.remove(reminder: reminderViewModel.reminder)
        self.refresh()
    }
}
