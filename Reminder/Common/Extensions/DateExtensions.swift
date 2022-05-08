//
//  DateExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

extension Date {
    func compare(date: Date, format: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let lhs = formatter.string(from: self)
        let rhs = formatter.string(from: date)
        return lhs > rhs ? 1 : (lhs == rhs ? 0 : -1)
    }

    func description(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Date {
    public var shortDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        return formatter.string(from: self)
    }
}

extension Date {
    public var calendar: Calendar {
        return NSCalendar.current
    }

    public var era: Int {
        return calendar.component(.era, from: self)
    }

    public var quarter: Int {
        return calendar.component(.quarter, from: self)
    }

    public var weekOfYear: Int {
        return calendar.component(.weekOfYear, from: self)
    }

    public var weekOfMonth: Int {
        return calendar.component(.weekOfMonth, from: self)
    }

    public var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.year = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.month = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.day = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var weekDayString: String {
        let weekDayString = ["", "", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return weekDayString[weekday]
    }
    
    public var weekDayFullString: String {
        let weekDayString = ["", "", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return weekDayString[weekday]
    }

    public var weekday: Int {
        get {
            return calendar.component(.weekday, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: self)
            component.weekday = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.hour = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.minute = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            component.second = newValue
            if let date = calendar.date(from: component) {
                self = date
            }
        }
    }

    public var nanosecond: Int {
        get {
            return calendar.component(.nanosecond, from: self)
        }
        set {
            if let date = calendar.date(bySetting: .nanosecond, value: newValue, of: self) {
                self = date
            }
        }
    }

    public var millisecond: Int {
        get {
            return calendar.component(.nanosecond, from: self) / 1000000
        }
        set {
            let nanoseconds = newValue * 1000000
            if let date = calendar.date(bySetting: .nanosecond, value: nanoseconds, of: self) {
                self = date
            }
        }
    }

    public var isInFuture: Bool {
        return self > Date()
    }

    public var isInPast: Bool {
        return self < Date()
    }

    public var isInToday: Bool {
        return calendar.isDateInToday(self)
    }

    public var isInYesterday: Bool {
        return calendar.isDateInYesterday(self)
    }

    public var isInTomorrow: Bool {
        return calendar.isDateInTomorrow(self)
    }

    public var isInWeekend: Bool {
        return calendar.isDateInWeekend(self)
    }

    public var isInWeekday: Bool {
        return !calendar.isDateInWeekend(self)
    }


    public var timeZone: TimeZone {
        return calendar.timeZone
    }

    public var unixTimestamp: Double {
        return timeIntervalSince1970
    }

    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(Double(milliseconds) / Double(1000)))
    }

    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    func getElapsedInterval() -> String {
        let componentsToNow = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())

        if componentsToNow.year! > 0 {
            return componentsToNow.year! == 1 ? "\(componentsToNow.year!) year ago" : "\(componentsToNow.year!) years ago"
        }

        if componentsToNow.month! > 0 {
            return componentsToNow.month! == 1 ? "\(componentsToNow.month!) month ago" : "\(componentsToNow.month!) months ago"
        }

        if componentsToNow.day! > 0 {
            return componentsToNow.day! == 1 ? "\(componentsToNow.day!) day ago" : "\(componentsToNow.day!) days ago"
        }

        if componentsToNow.hour! > 0 {
            return componentsToNow.hour! == 1 ? "\(componentsToNow.hour!) hour ago" : "\(componentsToNow.hour!) hours ago"
        }

        if componentsToNow.minute! > 0 {
            return componentsToNow.minute! == 1 ? "\(componentsToNow.minute!) minute ago" : "\(componentsToNow.minute!) minutes ago"
        }

        return "a moment ago"
    }

    var yesterDay: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var startOfDay: Date {
        let components = Calendar.current.dateComponents([.year,.day,.month], from: self)
        return Calendar.current.date(from: components)!
    }

    var startOfWeek: Date {
        let calendar = Calendar.gregorian()
        var components = calendar.dateComponents([.year,.month,.weekOfMonth,.weekday], from: self)
        components.weekday = 2

        return calendar.date(from: components)!
    }

    var startOfMonth: Date {
        let calendar = Calendar.gregorian()
        let components = calendar.dateComponents([.year,.month], from: self)

        return calendar.date(from: components)!
    }

    var endOfDay: Date {
        let startOfDay = self.tomorrow.startOfDay
        return startOfDay.addingTimeInterval(-1)
    }

    var eightPM: Date {
        return self.dateAt(hour: 20)
    }

    var tenPM: Date {
        return self.dateAt(hour: 22)
    }

    var sixAM: Date {
        return self.dateAt(hour: 6)
    }

    func dateAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.gregorian().dateComponents([.day, .month, .year, .hour], from: self)
        components.hour = hour
        components.minute = minute

        return Calendar.gregorian().date(from: components)!
    }
    
    func componentsFromDate(_ date: Date, components: [Calendar.Component] = [.day, .month, .year, .hour, .minute, .second, .weekday]) -> DateComponents {
        return self.calendar.dateComponents(Set(components), from: self, to: date)
    }
}
