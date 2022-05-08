//
//  ReminderRepeat.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation

enum ReminderRepeat: Int {
    case never = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    case yearly = 4
    
    var string: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        default:
            return "Never"
        }
    }
}
