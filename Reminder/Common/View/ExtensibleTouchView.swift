//
//  ExtensibleTouchView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit

public class ExtensibleTouchView: UIView {
    public var areaInteractiveInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.inset(by: areaInteractiveInsets).contains(point)
    }
}
