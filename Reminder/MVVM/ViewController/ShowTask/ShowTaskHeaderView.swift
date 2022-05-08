//
//  ShowTaskHeaderView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 25/02/2022.
//

import UIKit
protocol ShowTaskHeaderViewDelegate: AnyObject {
    func showTaskHeaderViewDidTapAddButton(_ view: ShowTaskHeaderView, category: Category)
}

class ShowTaskHeaderView: UIView {
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    init(category: Category) {
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.category = category
        self.commonInit()
        self.bindData()
    }
    
    // MARK: - Variables
    weak var delegate: ShowTaskHeaderViewDelegate?
    var isAddButtonHidden: Bool {
        get {
            return addButton.isHidden
        }
        
        set {
            addButton.isHidden = newValue
        }
    }
    
    private var category: Category!
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Nunito.semiboldFont(size: 20)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_plus_black"), for: .normal)
        button.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Common init
    private func commonInit() {
        self.backgroundColor = UIColor(rgb: 0xF3F9F9)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28),
            addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: addButton.leftAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Action
    @objc private func addButtonDidTap() {
        delegate?.showTaskHeaderViewDidTapAddButton(self, category: self.category)
    }
    
    // MARK: - Helper
    func bindData() {
        titleLabel.text = category.name
        titleLabel.textColor = category.color
    }
}
