//
//  StatisticsScreenViewModel.swift
//  Reminder
//
//  Created by linhnd99 on 30/03/2022.
//

import UIKit

enum StatisticsTab: Int {
    case completed = 0
    case pastTheDeadline = 1
    case stillGoing = 2
}

struct StatisticsScreenViewModel {
    private var reminderDao = DIContainer.shared.resolve(ReminderDao.self)
    private var categoryDao = DIContainer.shared.resolve(CategoryDao.self)
    
    private var listCompleted: [Reminder]!
    private var listPastTheDeadline: [Reminder]!
    private var listStillGoing: [Reminder]!
    private var categories: [Category]
    
    var tab: StatisticsTab
    
    init(tab: StatisticsTab = .completed) {
        self.tab = tab
        self.listCompleted = reminderDao.getAll().filter({ $0.isCompleted }).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.listPastTheDeadline = reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 < Date().timeIntervalSince1970}).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.listStillGoing = reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 > Date().timeIntervalSince1970}).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.categories = categoryDao.getAll()
    }
    
    mutating func refresh() {
        self.listCompleted = reminderDao.getAll().filter({ $0.isCompleted }).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.listPastTheDeadline = reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 < Date().timeIntervalSince1970}).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.listStillGoing = reminderDao.getAll().filter({!$0.isCompleted && $0.targetTime.timeIntervalSince1970 > Date().timeIntervalSince1970}).sorted(by: {($0.isCompleted ? 1 : 0) > ($1.isCompleted ? 1 : 0)})
        self.categories = categoryDao.getAll()
    }
    
    func numberOfSection() -> Int {
        return self.categories.count
    }
    
    func numberOfItem(in section: Int) -> Int {
        switch tab {
        case .completed:
            return self.listCompleted.filter({$0.categoryId == self.categories[section].id}).count
        case .pastTheDeadline:
            return self.listPastTheDeadline.filter({$0.categoryId == self.categories[section].id}).count
        case .stillGoing:
            return self.listStillGoing.filter({$0.categoryId == self.categories[section].id}).count
        }
    }
    
    func reminder(section: Int, index: Int) -> Reminder {
        switch tab {
        case .completed:
            return self.listCompleted.filter({$0.categoryId == self.categories[section].id})[index]
        case .pastTheDeadline:
            return self.listPastTheDeadline.filter({$0.categoryId == self.categories[section].id})[index]
        case .stillGoing:
            return self.listStillGoing.filter({$0.categoryId == self.categories[section].id})[index]
        }
    }
    
    mutating func setIsCompleted(_ value: Bool, for reminder: Reminder) {
        reminder.isCompleted = value
        reminderDao.addAndUpdate(reminder: reminder)
        self.refresh()
    }
    
    func category(at index: Int) -> Category {
        return self.categories[index]
    }
}
