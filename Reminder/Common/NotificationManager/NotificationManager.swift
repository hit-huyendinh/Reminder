//
//  NotificationManager.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 05/04/2022.
//

import UIKit
import UserNotifications

protocol NotificationManager {
    func requestPermission(completion:((Bool, Error?) -> Void)?)
    func fetchNotificationSettings()
    func scheduleNotification(title: String, body: String, date: Date)
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void)
    func cancelRequest(request: UNNotificationRequest)
    func cancelRequest(requestId: String)
    func scheduleNotification(reminder: Reminder) -> String?
}

final class NotificationManagerImpl: NotificationManager {
    static var shared = NotificationManagerImpl()
    private var currentNotification: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    private var settings: UNNotificationSettings?
    
    func requestPermission(completion:((Bool, Error?) -> Void)?) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            completion?(granted, error)
        }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.settings = settings
        }
    }
    
    func scheduleNotification(reminder: Reminder) -> String? {
        let content = UNMutableNotificationContent()
        content.title = reminder.name
        content.body = "Tap to detail"
        content.sound = .default
        
        var setComponent = Set<Calendar.Component>()
        setComponent.update(with: .second)
        setComponent.update(with: .minute)
        setComponent.update(with: .hour)
        
        switch reminder.remindingRepeat {
            case .yearly:
                setComponent.update(with: .month)
                setComponent.update(with: .day)
            case .monthly:
                setComponent.update(with: .day)
            case .weekly:
                setComponent.update(with: .weekday)
            default:
                break
        }
        
        let component: DateComponents?
        switch reminder.remindingTime {
            case .before1Hour:
                component = Calendar.current.dateComponents(setComponent, from: reminder.targetTime.addingTimeInterval(-60*60))
            case .before30Min:
                component = Calendar.current.dateComponents(setComponent, from: reminder.targetTime.addingTimeInterval(-60*30))
            case .before5Min:
                component = Calendar.current.dateComponents(setComponent, from: reminder.targetTime.addingTimeInterval(-60*5))
            case .on(let date):
                component = Calendar.current.dateComponents(setComponent, from: date)
            default:
                component = nil
        }
        
        guard let component = component else {
            return nil
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        if let nextTriggerDate = trigger.nextTriggerDate(),
           let endRepeatTimeInterval = reminder.remindingEndRepeat?.rawValue,
           endRepeatTimeInterval != -1,
           nextTriggerDate.timeIntervalSince1970 > endRepeatTimeInterval {
            return nil
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.currentNotification.add(request) { error in
            if let error = error {
                print("Add request notification error \(error)")
            }
        }
        return request.identifier
    }
    
    func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let component = Calendar.current.dateComponents([.year,.day,.month,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.currentNotification.add(request) { error in
            if let error = error {
                print("Add request notification error \(error)")
            }
        }
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        self.currentNotification.getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    func cancelRequest(request: UNNotificationRequest) {
        self.cancelRequest(requestId: request.identifier)
    }
    
    func cancelRequest(requestId: String) {
        self.currentNotification.removePendingNotificationRequests(withIdentifiers: [requestId])
    }
}
