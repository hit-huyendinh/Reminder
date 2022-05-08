//
//  BaseViewController.swift
//  Reminder
//
//  Created by linhnd99 on 28/03/2022.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    var isDisplaying: Bool = false
    var disposeBag = DisposeBag()
    private var isFirstAppear: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisplaying = true
        if isFirstAppear {
            self.viewWillFirstAppear()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            self.viewDidFirstAppear()
            self.isFirstAppear = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisplaying = false
    }
    
    func viewWillFirstAppear() {
        // nothing
    }
    
    func viewDidFirstAppear() {
        // nothing
    }
}
