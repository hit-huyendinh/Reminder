//
//  CategoryViewModel.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import UIKit

struct CategoryViewModel {
    var category: Category
    var date: Date?
    var reminders: [Reminder]!
    var nameFiltered: String?
    
    init(category: Category, date: Date? = nil, nameFiltered: String? = nil) {
        self.date = date
        self.category = category
        self.nameFiltered = nameFiltered
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        if let date = date {
            reminders = reminderDao.getReminders(categoryId: category.id, date: date)
        } else {
            reminders = reminderDao.getReminders(categoryId: category.id)
        }
        
        if let nameFiltered = nameFiltered {
            reminders = reminders.filter({$0.name.uppercased().contains(nameFiltered.uppercased())})
        }
    }
    
    func name() -> String {
        return category.name
    }

    func color() -> UIColor {
        return category.color
    }
    
    func image() -> UIImage {
        return UIImage(named: category.iconName)!
    }
    
    func imageName() -> String {
        return category.iconName
    }
    
    func numberOfReminders() -> Int {
        return reminders.count
    }
    
    func reminderAt(index: Int) -> ReminderViewModel {
        return ReminderViewModel(reminder: reminders[index])
    }
    
    func saveCategory() {
        let categoryDao = DIContainer.shared.resolve(CategoryDao.self)
        categoryDao.add(category: category)
    }
}
