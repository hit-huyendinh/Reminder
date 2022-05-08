//
//  LoadingHUD.swift
//  Reminder
//
//  Created by linhnd99 on 23/04/2022.
//

import UIKit
import Lottie

class LoadingHUD {
    static var shared = LoadingHUD()
    
    private var containerView: UIView!
    private var backgroundView: UIView!
    private var animateView: AnimationView!
    private var isDisplaying: Bool = false
    
    init() {
        self.containerView = UIView()
        self.containerView.backgroundColor = .clear
        
        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = .black
        self.backgroundView.alpha = 0.5
        self.containerView.addSubview(backgroundView)
        self.backgroundView.fitSuperviewConstraint()
        
        let jsonPath = Bundle.main.path(forResource: "loading", ofType: "json")!
        self.animateView = AnimationView(filePath: jsonPath)
        self.animateView.loopMode = .loop
        self.animateView.backgroundColor = .clear
        self.animateView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(animateView)
        NSLayoutConstraint.activate([
            self.animateView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor),
            self.animateView.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
            self.animateView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.animateView.widthAnchor.constraint(equalTo: self.animateView.heightAnchor)
        ])
    }
    
    static func show() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}),
              !shared.isDisplaying else {
            return
        }
        
        shared.containerView.alpha = 0
        shared.animateView.play()
        window.addSubview(shared.containerView)
        shared.containerView.fitSuperviewConstraint()
        window.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25) {
            shared.containerView.alpha = 1
            shared.isDisplaying = true
        }
    }
    
    static func dismiss() {
        if !shared.isDisplaying {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            shared.containerView.alpha = 1
            shared.isDisplaying = true
        } completion: { _ in
            shared.animateView.stop()
            shared.containerView.removeFromSuperview()
        }
    }
}
