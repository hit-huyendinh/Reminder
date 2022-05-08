//
//  OptionDialog.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 10/03/2022.
//

import UIKit

final class OptionDialog: UIViewController {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.25
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var containerStackView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.shadowColor = .black
        view.shadowOffset = .init(width: 0, height: 8)
        view.shadowOpacity = 0.1
        view.shadowRadius = 64
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.backgroundColor = UIColor(rgb: 0xFAFAFA)
        view.cornerRadius = 12
        return view
    }()
    
    private lazy var actions = [() -> Void]()
    private var topStackViewConstraint: NSLayoutConstraint!
    private var rightStackViewConstraint: NSLayoutConstraint!
    private var top: CGFloat = 0
    private var right: CGFloat = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(backgroundView)
        self.backgroundView.fitSuperviewConstraint()
        self.view.addSubview(containerStackView)
        containerStackView.addSubview(stackView)
        stackView.fitSuperviewConstraint()
        
        stackView.widthAnchor.constraint(equalToConstant: 260).isActive = true
        topStackViewConstraint = stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: top)
        rightStackViewConstraint = stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -right)
        NSLayoutConstraint.activate([topStackViewConstraint, rightStackViewConstraint])
    }
    
    // MARK: - Action
    @objc private func backgroundViewDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func actionButtonDidTap(button: TapableView) {
        self.dismiss(animated: true) {
            self.actions[button.tag]()
        }
    }
    
    // MARK: - Internal
    @discardableResult
    func addAction(title: String, image: UIImage, color: UIColor = .black, action: @escaping () ->Void) -> TapableView {
        let button = TapableView()
        button.scaleOnHighlight = 1
        
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.font = Nunito.regularFont(size: 17)
        let imageView = UIImageView(image: image)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label)
        button.addSubview(imageView)
        
        if !stackView.arrangedSubviews.isEmpty {
            let lineView = UIView()
            lineView.backgroundColor = UIColor(rgb: 0x3C3C43)
            lineView.alpha = 0.36
            lineView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.heightAnchor.constraint(equalToConstant: 1),
                lineView.leftAnchor.constraint(equalTo: lineView.superview!.leftAnchor),
                lineView.rightAnchor.constraint(equalTo: lineView.superview!.rightAnchor),
                lineView.topAnchor.constraint(equalTo: lineView.superview!.topAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageView.superview!.centerYAnchor),
            imageView.rightAnchor.constraint(equalTo: imageView.superview!.rightAnchor, constant: -13),
            
            label.leftAnchor.constraint(equalTo: label.superview!.leftAnchor, constant: 13),
            label.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: label.superview!.topAnchor),
            label.bottomAnchor.constraint(equalTo: label.superview!.bottomAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        actions.append(action)
        button.tag = stackView.arrangedSubviews.count
        button.addTarget(self, action: #selector(actionButtonDidTap(button:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        return button
    }
    
    func layoutContentView(top: CGFloat, right: CGFloat) {
        self.top = top
        self.right = right
        if self.isViewLoaded {
            topStackViewConstraint.constant = top
            rightStackViewConstraint.constant = -right
            self.view.layoutIfNeeded()
        }
    }
}
