//
//  CategoryDao.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation

protocol CategoryDao {
    func add(category: Category)
    func getAll() -> [Category]
    func getCategory(id: String) -> Category?
    func remove(category: Category)
    func getCategoriesInDate(_ date: Date) -> [Category]
}

final class CategoryDaoImpl: RealmDao, CategoryDao {
    func add(category: Category) {
        try? self.addObjectAndUpdate(category.rlmObject())
    }
    
    func getCategory(id: String) -> Category? {
        if let rlmObject = try? self.objectWithPrimaryKey(type: RLMCategory.self, key: id) {
            return Category(rlmObject: rlmObject)
        }
        
        return nil
    }
    
    func getCategoriesInDate(_ date: Date) -> [Category] {
        let reminderDao = DIContainer.shared.resolve(ReminderDao.self)
        return self.getAll().filter { category in
            reminderDao.getReminders(categoryId: category.id).contains(where: {$0.targetTime.compare(date: date, format: "yyyy/MM/dd") == 0})
        }
    }
    
    func getAll() -> [Category] {
        guard let result = try? self.objects(type: RLMCategory.self) else {
            return []
        }
        
        return result.map({ Category(rlmObject: $0) })
    }
    
    func remove(category: Category) {
        if let rlmObject = try? self.objectWithPrimaryKey(type: RLMCategory.self, key: category.id) {
            try? self.deleteObjects([rlmObject])
        }
    }
}
