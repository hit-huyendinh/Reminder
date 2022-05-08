//
//  DaoRegisterer.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import Swinject

class DaoRegisterer {
    static func registerDependencyForDaos(container: Container) {
        container.register(CategoryDao.self) { _ in
            return CategoryDaoImpl()
        }
        
        container.register(ReminderDao.self) { _ in
            return ReminderDaoImpl()
        }
    }
}
