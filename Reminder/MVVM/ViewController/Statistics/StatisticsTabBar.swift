//
//  StatisticsTabBar.swift
//  Reminder
//
//  Created by linhnd99 on 29/03/2022.
//

import UIKit

final class StatisticsTabBarItem: TapableView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    var isHighLight: Bool = false {
        didSet {
            if titleLabel != nil {
                titleLabel.textColor = isHighLight ? UIColor(rgb: 0x008081) : .black.withAlphaComponent(0.7)
            }
        }
    }
    
    var title: String = "Button" {
        didSet {
            if titleLabel != nil {
                titleLabel.text = title
                titleLabel.sizeToFit()
            }
        }
    }
    
    private var titleLabel: UILabel!
    
    private func commonInit() {
        self.scaleOnHighlight = 1
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Nunito.semiboldFont(size: 14)
        titleLabel.textColor = isHighLight ? UIColor(rgb: 0x008081) : .black.withAlphaComponent(0.7)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
        ])
    }
}

class StatisticsTabBar: UIView {
    private var scrollView: UIScrollView!
    private var contentScrollView: UIStackView!
    private var selectedLineView: UIView!
    
    private var widthSelectedLineViewConstraint: NSLayoutConstraint!
    private var leftSelectedLineViewConstraint: NSLayoutConstraint!
    private var lastConstraint: NSLayoutConstraint?
    private var actions = [() -> Void]()
    
    var selectedIndex: Int = 0
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: - CommonInit
    private func commonInit() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset.left = 15
        scrollView.contentInset.right = 15
        
        contentScrollView = UIStackView()
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.backgroundColor = .clear
        contentScrollView.axis = .horizontal
        contentScrollView.spacing = 15
        
        selectedLineView = UIView()
        selectedLineView.translatesAutoresizingMaskIntoConstraints = false
        selectedLineView.backgroundColor = UIColor(rgb: 0x008081)
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentScrollView)
        contentScrollView.addSubview(selectedLineView)
        
        leftSelectedLineViewConstraint = selectedLineView.leftAnchor.constraint(equalTo: self.contentScrollView.leftAnchor)
        widthSelectedLineViewConstraint = selectedLineView.widthAnchor.constraint(equalToConstant: 10)
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            scrollView.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: contentScrollView.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            selectedLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            selectedLineView.heightAnchor.constraint(equalToConstant: 2),
            leftSelectedLineViewConstraint,
            widthSelectedLineViewConstraint
        ])
    }
    
    func addItem(title: String, action: @escaping () -> Void) {
        self.actions.append(action)
        let button = StatisticsTabBarItem()
        button.title = title
        button.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor)
        ])
        
        button.tag = self.actions.count-1
        button.addTarget(self, action: #selector(tabBarItemDidTap(_:)), for: .touchUpInside)
        
        if self.actions.count == 1 {
            contentScrollView.layoutIfNeeded()
            self.widthSelectedLineViewConstraint.constant = button.frame.width
            self.leftSelectedLineViewConstraint.constant = button.frame.minX
            self.contentScrollView.layoutIfNeeded()
        }
    }
    
    @objc private func tabBarItemDidTap(_ item: TapableView) {
        self.actions[item.tag]()
        self.selectedIndex = item.tag
        self.scrollView.scrollRectToVisible(item.frame, animated: true)
        UIView.animate(withDuration: 0.25) {
            self.reloadContentScrollView()
            self.widthSelectedLineViewConstraint.constant = item.frame.width
            self.leftSelectedLineViewConstraint.constant = item.frame.minX
            self.contentScrollView.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper
    func reloadContentScrollView() {
        contentScrollView.subviews.forEach { view in
            if let view = view as? StatisticsTabBarItem {
                view.isHighLight = view.tag == self.selectedIndex
            }
        }
    }
}
