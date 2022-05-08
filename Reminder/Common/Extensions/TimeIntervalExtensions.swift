//
//  TimeIntervalExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import AVFoundation

extension TimeInterval {
    func toDurationString() -> String {
        let timeInterval = ceil(self)
        let seconds: Int = Int(timeInterval) % 60
        let minutes = Int(timeInterval / 60)
        return String.init(format: "%02d:%02d", minutes, seconds)
    }
}

extension CMTime {
    func toDouble() -> Float64 {
        return CMTimeGetSeconds(self)
    }
}
