//
//  MyCategoryView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 24/02/2022.
//

import UIKit

protocol MyCategoryViewDelegate: AnyObject {
    func myCategoryViewDidTap(_ view: MyCategoryView)
}

class MyCategoryView: TapableView {
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
        self.commonInit()
        self.setCategory(category)
    }
    
    // MARK: - Properties
    private var imageView = UIImageView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x212121)
        label.font = Nunito.semiboldFont(size: 16)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x212121)
        label.font = Nunito.regularFont(size: 12)
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var reminderDao: ReminderDao = {
        return DIContainer.shared.resolve(ReminderDao.self)
    }()
    
    weak var delegate: MyCategoryViewDelegate?
    var category: Category!
    
    // MARK: - Common init
    private func commonInit() {
        self.backgroundColor = .white
        self.cornerRadius = 12
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.leftAnchor.constraint(equalTo: imageView.superview!.leftAnchor, constant: 20),
            imageView.centerYAnchor.constraint(equalTo: imageView.superview!.centerYAnchor),
            
            contentView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: contentView.superview!.rightAnchor, constant: 20),
            contentView.centerYAnchor.constraint(equalTo: contentView.superview!.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            
            subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            subtitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        self.addTarget(self, action: #selector(selfDidTap), for: .touchUpInside)
    }
    
    func setCategory(_ category: Category) {
        self.category = category
        imageView.image = UIImage(named: category.iconName)
        titleLabel.text = category.name
        let numberOfTask = reminderDao.getReminders(categoryId: category.id).count
        subtitleLabel.text = "\(numberOfTask) Task\(numberOfTask > 1 ? "s" : "")"
    }
    
    // MARK: - Action
    @objc private func selfDidTap() {
        delegate?.myCategoryViewDidTap(self)
    }
}
