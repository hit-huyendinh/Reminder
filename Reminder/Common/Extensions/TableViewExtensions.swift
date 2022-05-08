//
//  TableViewExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import UIKit

extension UITableView {
    func registerCell<T>(type: T.Type) {
        let name = String(describing: type)
        self.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }

    func dequeueCell<T>(type: T.Type) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableCell(withIdentifier: name) as? T
    }

    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableCell(withIdentifier: name, for: indexPath) as? T
    }
}
