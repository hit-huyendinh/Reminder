//
//  AppDelegate.swift
//  Remainder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(FileManager.documentURL())
        initListCategoryWhenFirstLaunchApp()
        // fakeDataToCheckPieChart()
        configWindow()
        configFirebase()
        configAppearance()
        configNotification()
        return true
    }
    
    func configFirebase() {
        FirebaseApp.configure()
    }
    
    func configWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light
        
        let homeVC = HomeViewController()
        let nav = BaseNavigationController(rootViewController: homeVC)
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    func configAppearance() {
        UIView.appearance().isExclusiveTouch = true
        UIControl.appearance().isExclusiveTouch = true
    }
    
    func configNotification() {
        DIContainer.shared.resolve(NotificationManager.self).requestPermission(completion: nil)
        UNUserNotificationCenter.current().delegate = self
        DIContainer.shared.resolve(NotificationManager.self).fetchNotificationSettings()
    }
    
    func initListCategoryWhenFirstLaunchApp() {
        if !UserDefaults.standard.bool(forKey: "hasPreviousUsing") {
            let categoryDao = DIContainer.shared.resolve(CategoryDao.self)
            
            let category1 = Category(name: "Work", iconName: "ic_work", color: UIColor(rgb: 0x88A5DD))
            category1.id = "category_work"
            categoryDao.add(category: category1)
            
            let category2 = Category(name: "Learning", iconName: "ic_learning", color: UIColor(rgb: 0xD68060))
            category2.id = "category_learning"
            categoryDao.add(category: category2)
            
            let category3 = Category(name: "Birthday", iconName: "ic_birthday", color: UIColor(rgb: 0xFA9191))
            category3.id = "category_birthday"
            categoryDao.add(category: category3)
            
            UserDefaults.standard.set(true, forKey: "hasPreviousUsing")
        }
    }
    
    func fakeDataToCheckPieChart() {
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        let categoryDao = DIContainer.shared.resolve(CategoryDao.self)
        for _ in 0 ..< 5 {
            let reminder = Reminder(name: "reminder \(UUID().uuidString.prefix(3))", categoryId: categoryDao.getAll().randomElement()!.id)
            reminder.isCompleted = true
            reminderDao.addAndUpdate(reminder: reminder)
        }
        
        for _ in 0 ..< 5 {
            let reminder = Reminder(name: "reminder \(UUID().uuidString.prefix(3))", categoryId: categoryDao.getAll().randomElement()!.id)
            reminder.isCompleted = false
            reminder.targetTime = Date().addingTimeInterval(1000000)
            reminderDao.addAndUpdate(reminder: reminder)
        }
        
        for _ in 0 ..< 5 {
            let reminder = Reminder(name: "reminder \(UUID().uuidString.prefix(3))", categoryId: categoryDao.getAll().randomElement()!.id)
            reminder.isCompleted = false
            reminder.targetTime = Date().addingTimeInterval(-10000)
            reminderDao.addAndUpdate(reminder: reminder)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Local Notification :: ", response)
    }
}

