//
//  RealmManager.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//
import Foundation
import RealmSwift

enum RealmSchemaVersion: UInt64 {
    case first = 0
}

class RealmManager {
    static func configRealm() {
        
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = RealmSchemaVersion.first.rawValue
        config.migrationBlock = { _, _ in
            
        }
        
        Realm.Configuration.defaultConfiguration = config
        do {
            _ = try Realm()
        } catch {
            print("Realm need migration. Delete app if in dev mode")
            fatalError()
        }
    }
}
