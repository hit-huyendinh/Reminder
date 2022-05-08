//
//  ColorExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
    }
    
    func getRGB() -> Int {
        var red: CGFloat! = 0
        var green: CGFloat! = 0
        var blue: CGFloat! = 0
        var alpha: CGFloat! = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red*alpha*255)
        let greenInt = Int(green*alpha*255)
        let blueInt = Int(blue*alpha*255)
        
        return redInt << 16 + greenInt << 8 + blueInt
    }
}
