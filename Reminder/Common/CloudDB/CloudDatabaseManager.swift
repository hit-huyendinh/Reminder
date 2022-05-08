//
//  CloudDatabaseManager.swift
//  Reminder
//
//  Created by linhnd99 on 15/04/2022.
//

import Firebase
import FirebaseDatabase
import UIKit

private struct Const {
    static let kCategories = "Categories"
    static let kReminders = "Reminders"
    static let kHashCode = "HashCode"
}
protocol CloudDatabaseManagerGetter {
    func getCategories(userId: String, completion: @escaping ([Category]?, Error?) -> Void)
    func getReminders(userId: String, completion: @escaping ([Reminder]?, Error?) -> Void)
    func getHashCode(userId: String, completion: @escaping ((String?, Error?) -> Void))
}

protocol CloudDatabaseManagerSetter {
    func addCategories(_ categories: [Category], userId: String, completion:((Error?)->Void)?)
    func addReminders(_ reminders: [Reminder], userId: String, completion: ((Error?) -> Void)?)
}

protocol CloudDatabaseManager: CloudDatabaseManagerGetter, CloudDatabaseManagerSetter {
    func backup(userId: String, completion:((Error?) -> Void)?)
    func pull(userId: String, completion:((Error?) -> Void)?)
}

// MARK: - CloudDatabaseManagerImpl
final class CloudDatabaseManagerImpl {
    static var shared = CloudDatabaseManagerImpl()
    
    private lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    private lazy var categoryDao: CategoryDao = {
        return DIContainer.shared.resolve(CategoryDao.self)
    }()
    
    private lazy var reminderDao: ReminderDao = {
        return DIContainer.shared.resolve(ReminderDao.self)
    }()
    
    func categories(from any: Any?) -> [Category] {
        return (any as? NSArray)?.compactMap { record in
            if let data = try? JSONSerialization.data(withJSONObject: record, options: .fragmentsAllowed),
               let cdObject = try? JSONDecoder().decode(CDCategory.self, from: data) {
                return Category(cdObject: cdObject)
            }
            return nil
        } ?? []
    }
    
    func reminders(from any: Any?) -> [Reminder] {
        return (any as? NSArray)?.compactMap { record in
            if let data = try? JSONSerialization.data(withJSONObject: record, options: .fragmentsAllowed),
               let cdObject = try? JSONDecoder().decode(CDReminder.self, from: data) {
                return Reminder(cdObject: cdObject)
            }
            return nil
        } ?? []
    }
}

// MARK: - CloudDatabaseManager
extension CloudDatabaseManagerImpl: CloudDatabaseManager {
    func backup(userId: String, completion:((Error?) -> Void)?) {
        let categories = self.categoryDao.getAll()
        var reminders = [Reminder]()
        for category in categories {
            reminders.append(contentsOf: self.reminderDao.getReminders(categoryId: category.id))
        }
        
        do {
            let categoriesData = try JSONEncoder().encode(categories.map({$0.cdObject()}))
            let categoriesJson = try JSONSerialization.jsonObject(with: categoriesData)
            
            let remindersData = try JSONEncoder().encode(reminders.map({$0.cdObject()}))
            let remindersJson = try JSONSerialization.jsonObject(with: remindersData)
            
            DispatchQueue.global().async {
                var backupError: Error? = nil
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                
                dispatchGroup.enter()
                self.ref.child(userId).child(Const.kCategories).setValue(categoriesJson) {
                    error, _ in
                    if error != nil {
                        backupError = error
                    }
                    
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                self.ref.child(userId).child(Const.kReminders).setValue(remindersJson) { error, _ in
                    if error != nil {
                        backupError = error
                    }
                    
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                let hashCode = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                self.ref.child(userId).child(Const.kHashCode).setValue(hashCode) {
                    error, _ in
                    if error != nil {
                        backupError = error
                    }
                    
                    dispatchGroup.leave()
                }
                
                dispatchGroup.leave()
                dispatchGroup.wait()
                DispatchQueue.main.async {
                    if backupError == nil {
                        UserDefaults.standard.set(hashCode, forKey: "kHashCode")
                    }
                    
                    completion?(backupError)
                }
            }
        } catch {
            completion?(error)
        }
    }
    
    func pull(userId: String, completion:((Error?) -> Void)?) {
        DispatchQueue.global().async {
            var pullError: Error? = nil
            var categoriesFromServer = [Category]()
            var remindersFromServer = [Reminder]()
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            dispatchGroup.enter()
            self.getCategories(userId: userId) { list, error in
                if let list = list {
                    categoriesFromServer = list
                } else {
                    pullError = error
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            self.getReminders(userId: userId) { list, error in
                if let list = list {
                    remindersFromServer = list
                } else {
                    pullError = error
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            self.ref.child(userId).child(Const.kHashCode).getData { error, snapshot in
                if error != nil {
                    pullError = error
                }
                
                let hashCode = snapshot.value as? String
                UserDefaults.standard.set(hashCode, forKey: "kHashCode")
                dispatchGroup.leave()
            }
            
            dispatchGroup.leave()
            dispatchGroup.wait()
            
            if pullError != nil {
                DispatchQueue.main.async {
                    completion?(pullError)
                }
                
                return
            }
            
            for category in categoriesFromServer {
                self.categoryDao.add(category: category)
            }
            
            for reminder in remindersFromServer {
                self.reminderDao.addAndUpdate(reminder: reminder)
            }
            
            DispatchQueue.main.async {
                completion?(nil)
            }
        }
    }
}

// MARK: - CloudDatabaseManagerGetter
extension CloudDatabaseManagerImpl: CloudDatabaseManagerGetter {
    func getHashCode(userId: String, completion: @escaping ((String?, Error?) -> Void)) {
        self.ref.child(userId).child(Const.kHashCode).getData { error, snapshot in
            if let error = error {
                print("Get hash code of \(userId) error: \(error)")
                completion(nil, error)
                return
            }
            
            completion(snapshot.value as? String, nil)
        }
    }
    
    func getCategories(userId: String, completion: @escaping ([Category]?, Error?) -> Void) {
        self.ref.child(userId).child(Const.kCategories).getData { error, snapshot in
            if let error = error {
                print("Get categories of \(userId) error: \(error)")
                completion(nil , error)
                return
            }
            
            let categories = self.categories(from: snapshot.value)
            completion(categories, nil)
        }
    }
    
    func getReminders(userId: String, completion: @escaping ([Reminder]?, Error?) -> Void) {
        self.ref.child(userId).child(Const.kReminders).getData { error, snapshot in
            if let error = error {
                print("Get categories of \(userId) error: \(error)")
                completion(nil, error)
                return
            }
            
            let reminders = self.reminders(from: snapshot.value)
            completion(reminders, nil)
        }
    }
}

// MARK: - CloudDatabaseManagerSetter
extension CloudDatabaseManagerImpl: CloudDatabaseManagerSetter {
    func addCategories(_ categories: [Category], userId: String, completion:((Error?)->Void)?) {
        self.getCategories(userId: userId) { currentCategories, error in
            if let error = error {
                print(error)
                completion?(error)
                return
            }
            
            var currentCategories = currentCategories ?? []
            currentCategories.append(contentsOf: categories)
            do {
                let data = try JSONEncoder().encode(currentCategories.map({$0.cdObject()}))
                let json = try JSONSerialization.jsonObject(with: data)
                self.ref.child(userId).child(Const.kCategories).setValue(json)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func addReminders(_ reminders: [Reminder], userId: String, completion: ((Error?) -> Void)?) {
        self.getReminders(userId: userId) { currentReminders, error in
            if let error = error {
                print(error)
                completion?(error)
                return
            }
            
            var currentReminders = currentReminders ?? []
            currentReminders.append(contentsOf: reminders)
            do {
                let data = try JSONEncoder().encode(currentReminders.map({$0.cdObject()}))
                let json = try JSONSerialization.jsonObject(with: data)
                self.ref.child(userId).child(Const.kReminders).setValue(json)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
