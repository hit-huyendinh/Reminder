//
//  AVPlayerExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import AVFoundation

extension AVPlayer {
    func seek(to time: CMTime) {
        self.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
