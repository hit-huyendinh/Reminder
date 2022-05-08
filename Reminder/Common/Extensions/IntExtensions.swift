//
//  IntExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

extension Int {
    func timeString() -> String {        
        let minute = self / 60 % 60
        let second = self % 60

        // return formated string
        return String(format: "%02d:%02d", minute, second)
    }
}
