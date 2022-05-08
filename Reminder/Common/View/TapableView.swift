//
//  TapableView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit

open class TapableView: UIControl {
    @IBInspectable var scaleOnHighlight: CGFloat = 0.8
    @IBInspectable var delayEventDuration: Double = 0.5
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.animate(alpha: 0.6, scale: self.scaleOnHighlight)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animate(alpha: 1, scale: 1)
        
        let location = touches.first!.location(in: self)
        if self.bounds.contains(location) {
            self.sendActions(for: .touchUpInside)
            self.disableInteractiveFor(seconds: delayEventDuration)
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.animate(alpha: 1, scale: 1)
    }

    private func animate(alpha: CGFloat, scale: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
            if scale == 1 {
                self.transform = .identity
            } else {
                self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        }
    }
}
