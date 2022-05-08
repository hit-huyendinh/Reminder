//
//  CalendarTaskViewModel.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 13/03/2022.
//

import UIKit

struct CalendarTaskItemViewModel {
    private var categoryDao = DIContainer.shared.resolve(CategoryDao.self)
    var reminder: Reminder
    
    init(reminder: Reminder) {
        self.reminder = reminder
    }
    
    func color() -> UIColor {
        categoryDao.getCategory(id: reminder.categoryId)?.color ?? .clear
    }
    
    func timeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: reminder.targetTime)
    }
    
    func name() -> String {
        return reminder.name
    }
}

struct CalendarTaskViewModel {
    private var reminderDao = DIContainer.shared.resolve(ReminderDao.self)
    private var categoryDao = DIContainer.shared.resolve(CategoryDao.self)
    
    private var cached: [Date: [Reminder]]!
    private var sections: [Date]!
    
    var date: Date {
        didSet {
            self.reloadCached()
        }
    }
    
    init(date: Date) {
        self.date = date
        self.reloadCached()
    }
    
    func startWeekDate() -> Date {
        var newDate = date
        while newDate.weekday != 3 { // ! isMonday
            newDate = newDate.yesterDay
        }
        return newDate
    }
    
    func endWeekDate() -> Date {
        var newDate = date
        while newDate.weekday != 2 { // ! isSunday
            newDate = newDate.tomorrow
        }
        
        return newDate
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(at section: Int) -> Int {
        return cached[sections[section]]?.count ?? 0
    }
    
    func item(at index: Int, section: Int) -> CalendarTaskItemViewModel {
        return CalendarTaskItemViewModel(reminder: cached[sections[section]]![index])
    }
    
    func dateFor(section: Int) -> Date {
        return sections[section]
    }
    
    func colorsAt(date: Date) -> [UIColor] {
        return reminderDao.getAll()
            .filter({$0.targetTime.compare(date: date, format: "yyyy/MM/dd") == 0})
            .sorted(by: {$0.targetTime.timeIntervalSince1970 < $1.targetTime.timeIntervalSince1970})
            .map({categoryDao.getCategory(id: $0.categoryId)!.color})
    }
    
    mutating func setDate(_ date: Date) {
        self.date = date
        self.reloadCached()
    }
    
    private mutating func reloadCached() {
        cached = [Date: [Reminder]]()
        sections = []
        var element = startWeekDate()
        while element <= endWeekDate() {
            cached[element] = reminderDao.getAll()
                .filter({$0.targetTime.compare(date: element, format: "yyyy/MM/dd") == 0})
                .sorted(by: {$0.targetTime.timeIntervalSince1970 < $1.targetTime.timeIntervalSince1970})
            if cached[element]?.isEmpty == false {
                sections.append(element)
            }
            
            element = element.addingTimeInterval(24*60*60.0)
        }
    }
}
