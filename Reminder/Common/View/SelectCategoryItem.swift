//
//  SelectCategoryItem.swift
//  Reminder
//
//  Created by linhnd99 on 03/05/2022.
//

import UIKit

protocol SelectCategoryItemDelegate: AnyObject {
    func selectCategoryItemDidSelected(_ view: SelectCategoryItem)
}

final class SelectCategoryItem: TapableView {
    weak var delegate: SelectCategoryItemDelegate?
    var category: Category? {
        didSet {
            self.titleLabel.text = category?.name ?? "+ New"
            self.containerView.borderColor = category == nil ? .black : .clear
            self.containerView.borderWidth = category == nil ? 1 : 0
            self.containerView.backgroundColor = category?.color ?? .clear
            self.titleLabel.textColor = category == nil ? .black : .white
            if category == nil {
                self.containerView.backgroundColor = .clear
            }
        }
    }
    
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var selectedImageView: UIImageView!
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        self.containerView = UIView()
        self.containerView.cornerRadius = 4
        self.containerView.isUserInteractionEnabled = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = Poppins.regularFont(size: 12)
        self.titleLabel.textColor = .white
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.selectedImageView = UIImageView(image: UIImage(named: "ic_selected"))
        self.selectedImageView.isHidden = true
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.addSubview(self.selectedImageView)
        
        self.titleLabel.fitSuperviewConstraint()
        self.containerView.fitSuperviewConstraint()
        NSLayoutConstraint.activate([
            self.selectedImageView.widthAnchor.constraint(equalTo: self.selectedImageView.heightAnchor),
            self.selectedImageView.widthAnchor.constraint(equalToConstant: 16),
            self.selectedImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: -8),
            self.selectedImageView.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: 8)
        ])
        
        self.addTarget(self, action: #selector(selfDidTap), for: .touchUpInside)
    }
    
    // MARK: - Helper
    @objc private func selfDidTap() {
        self.delegate?.selectCategoryItemDidSelected(self)
    }
    
    func select() {
        self.selectedImageView.isHidden = false
    }
    
    func unselect() {
        self.selectedImageView.isHidden = true
    }
}
