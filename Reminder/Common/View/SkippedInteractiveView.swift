//
//  SkippedInteractiveView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit

class SkippedInteractiveView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTest = super.hitTest(point, with: event)
        return hitTest == self ? nil : hitTest
    }
}
