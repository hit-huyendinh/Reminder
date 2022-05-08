//
//  CDReminder.swift
//  Reminder
//
//  Created by linhnd99 on 16/04/2022.
//

import Foundation

struct CDReminder: Codable {
    var id: String
    var name: String
    var createdTime: TimeInterval
    var targetTime: TimeInterval
    var remindingTime: Double
    var remindingRepeat: Int
    var remindingEndRepeat: Double?
    var isCompleted: Bool
    var categoryId: String
    var requestNotificationId: String?
}
