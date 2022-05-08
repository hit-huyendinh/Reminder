//
//  RemindingTime.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import UIKit

enum RemindingTime {   
    case never
    case on(Date)
    case before5Min
    case before30Min
    case before1Hour
    
    init(rawValue: Double) {
        switch rawValue {
        case -1:
            self = .never
        case 1:
            self = .before5Min
        case 2:
            self = .before30Min
        case 3:
            self = .before1Hour
        default:
            let date = Date(timeIntervalSince1970: rawValue/10)
            self = .on(date)
        }
    }
    
    var rawValue: Double {
        switch self {
        case .on(let date):
            return date.timeIntervalSince1970*10
        case .before5Min:
            return 1
        case .before30Min:
            return 2
        case .before1Hour:
            return 3
        case .never:
            return -1
        }
    }

    var string: String {
        switch self {
            case .never:
                return "Never"
            case .on(let date):
                return "\(date.weekDayString)\(date.description(format: ", dd MMM yyyy"))"
            case .before5Min:
                return "5 minutes early"
            case .before30Min:
                return "30 minutes early"
            case .before1Hour:
                return "1 hour early"
        }
    }
}
