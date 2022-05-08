//
//  AVAudioPlayerNodeExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import AVFoundation

extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        if let nodeTime = lastRenderTime,let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}
