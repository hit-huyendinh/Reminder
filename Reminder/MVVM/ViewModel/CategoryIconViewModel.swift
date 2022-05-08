//
//  CategoryIconViewModel.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 10/03/2022.
//

import UIKit

struct CategoryIconViewModel {
    private var icons: [String] = [
        "ic_work",
        "ic_learning",
        "ic_birthday",
        "ic_shopping",
        "ic_user",
        "ic_sport",
        "ic_pawprint",
        "ic_cutlery",
        "ic_medicine",
        "ic_football",
        "ic_televisions",
        "ic_console",
        "ic_home",
        "ic_plane",
        "ic_sun",
        "ic_plant",
        "ic_musical_note",
        "ic_credit_card",
        "ic_car",
        "ic_piggy_bank",
        "ic_weight",
        "ic_exercises",
        "ic_heart",
        "ic_camping_tent",
    ]
    
    private var colors: [Int] = [
        0x88A5DD,
        0xD68060,
        0xFA9191,
        0xD291BC,
        0x958EFB,
        0x6886C5,
        0xEEBB4D,
        0xBB6464,
        0x8BCDCD,
        0xD18CE0,
        0x54BAB9,
        0xFFB2A6,
        0xAD8B73,
        0x9ADCFF,
        0xFFF89A,
        0x8DB596,
        0xFF8AAE,
        0xFFC4E1,
        0xF6D7A7,
        0xFDCEB9,
        0xCE7BB0,
        0x9D5353,
        0xEEC373,
        0xFFC4E1
    ]
    
    func numberOfIcon() -> Int {
        return icons.count
    }
    
    func iconName(at index: Int) -> String {
        return icons[index]
    }
    
    func icon(at index: Int) -> UIImage {
        return UIImage(named: iconName(at: index))!
    }
    
    func color(at index: Int) -> UIColor {
        return UIColor(rgb: colors[index])
    }
    
    func rgbColor(at index: Int) -> Int {
        return colors[index]
    }
}
