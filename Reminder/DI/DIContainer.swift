//
//  DIContainer.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import Swinject

class DIContainer {
    static let shared = DIContainer()
    private let container = Container()

    init() {
        register()
    }

    func register() {
        DaoRegisterer.registerDependencyForDaos(container: container)
        self.registerNotificationManager()
        self.registerCloudDatabaseManager()
        self.registerUserContext()
    }

    // MARK: - Helper
    func resolve<Service>(_ serviceType: Service.Type) -> Service {
        if Thread.isMainThread {
            return self.container.resolve(serviceType)!
        } else {
            var service:Service?

            DispatchQueue.main.sync {[weak self] in
                service = self?.container.resolve(serviceType)
            }

            return service!
        }
    }

    func resolve<Service, Arg1>(_ serviceType: Service.Type, agrument: Arg1) -> Service {
        if Thread.isMainThread {
            return self.container.resolve(serviceType, argument: agrument)!
        } else {
            var service:Service?

            DispatchQueue.main.sync {[weak self] in
                service = self?.container.resolve(serviceType, argument: agrument)
            }

            return service!
        }
    }
    
    // MARK: - Register
    private func registerNotificationManager () {
        self.container.register(NotificationManager.self) { _ in
            return NotificationManagerImpl.shared
        }
    }
    
    private func registerCloudDatabaseManager() {
        self.container.register(CloudDatabaseManager.self) { _ in
            return CloudDatabaseManagerImpl.shared
        }
    }
    
    private func registerUserContext() {
        self.container.register(UserContext.self) { _ in
            return UserContextImpl.shared
        }
    }
}
