//
//  FloatExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation

extension Float {
    func ceil() -> Float {
        return ceilf(self)
    }

    func prettyString() -> String {
        if self == Float(Int(self)) {
            return "\(Int(self))"
        } else {
            return "\(self)"
        }
    }

    func prettyString(numberDigit: Int) -> String {
        if self == Float(Int(self)) {
            return "\(Int(self))"
        } else {
            let format = "%.0\(numberDigit)f"
            return String.init(format: format, self)
        }
    }

    func round(digit: Int) -> Float {
        let multipler = powf(10, Float(digit))

        return (self * multipler).rounded() / multipler
    }
}
