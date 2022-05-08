//
//  UIViewControllerExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import UIKit

extension UIViewController {
    func topVC() -> UIViewController {
        if let navigation = self as? UINavigationController, !navigation.viewControllers.isEmpty {
            return navigation.topViewController!.topVC()
        }
        
        if let presentedVC = self.presentedViewController {
            return presentedVC.topVC()
        }
        
        return self
    }
}
