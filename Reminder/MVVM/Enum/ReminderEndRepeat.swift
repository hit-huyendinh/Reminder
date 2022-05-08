//
//  ReminderEndRepeat.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import Foundation

enum ReminderEndRepeat: Equatable {
    case forever
    case on(Date)
    
    init(rawValue: Double) {
        if rawValue == -1 {
            self = .forever
        } else {
            let date = Date(timeIntervalSince1970: rawValue)
            self = .on(date)
        }
    }
    
    var rawValue: Double {
        switch self {
        case .forever:
            return -1
        case .on(let date):
            return date.timeIntervalSince1970
        }
    }
    
    var string: String? {
        switch self {
        case .forever:
            return "Forever"
        case .on(let date):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return "Util \(dateFormatter.string(from: date))"
        }
    }
    
    static func == (_ lhs: ReminderEndRepeat, _ rhs: ReminderEndRepeat) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
