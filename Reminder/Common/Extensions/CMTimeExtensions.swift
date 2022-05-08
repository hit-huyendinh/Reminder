//
//  CMTimeExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import AVFoundation

extension CMTime {
    func descriptionString() -> String {
        let second = Int(self.seconds.rounded())
        let hh = Int(second / 3600)
        let mm = Int(second % 3600 / 60)
        let ss = second % 60
        
        if hh == 0 && mm == 0 && ss == 0 && self.seconds > 0 {
            return "00:01"
        }
        
        if hh == 0 {
            return String(format: "%02d:%02d", mm,ss)
        }
        
        return String(format: "%02d:%02d:%02d", hh,mm,ss)
    }
    
    func fullDescriptionString() -> String {
        let second = Int(self.seconds.rounded())
        let hh = Int(second / 3600)
        let mm = Int(second % 3600 / 60)
        let ss = second % 60
        
        if hh == 0 && mm == 0 && ss == 0 && self.seconds > 0 {
            return "00:00:01"
        }
        
        return String(format: "%02d:%02d:%02d", hh,mm,ss)
    }
    
    func shortDescriptionString() -> String {
        let second = Int(self.seconds.rounded())
        let ss = second % 60
        let mm = second / 60
        
        if mm == 0 && ss == 0 && self.seconds > 0 {
            return "00:01"
        }
        
        return String(format: "%02d:%02d", mm, ss)
    }
}
