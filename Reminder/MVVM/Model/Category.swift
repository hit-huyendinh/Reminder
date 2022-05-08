//
//  Category.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit

class Category {
    var id: String = UUID().uuidString
    var name: String
    var iconName: String
    var color: UIColor
    
    init(name: String, iconName: String, color: UIColor = .black) {
        self.name = name
        self.iconName = iconName
        self.color = color
    }
    
    init(rlmObject: RLMCategory) {
        self.id = rlmObject.id
        self.name = rlmObject.name
        self.iconName = rlmObject.iconName
        self.color = UIColor(rgb: rlmObject.color)
    }
    
    init(cdObject: CDCategory) {
        self.id = cdObject.id
        self.name = cdObject.name
        self.iconName = cdObject.iconName
        self.color = UIColor(rgb: cdObject.color)
    }
    
    func rlmObject() -> RLMCategory {
        let rlmObject = RLMCategory()
        rlmObject.id = self.id
        rlmObject.name = self.name
        rlmObject.iconName = self.iconName
        rlmObject.color = self.color.getRGB()
        return rlmObject
    }
    
    func cdObject() -> CDCategory {
        return CDCategory(id: self.id,
                          name: self.name,
                          iconName: self.iconName,
                          color: self.color.getRGB())
    }
}
