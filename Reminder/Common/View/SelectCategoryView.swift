//
//  SelectCategoryView.swift
//  Reminder
//
//  Created by linhnd99 on 03/05/2022.
//

import UIKit

private struct Const {
    static let numberOfColumns: Int = 4
}

protocol SelectCategoryViewDelegate: AnyObject {
    func selectCategoryView(_ view: SelectCategoryView, didSelectCategory category: Category?)
}

class SelectCategoryView: UIView {
    weak var delegate: SelectCategoryViewDelegate?
    var listCategory = [Category]() {
        didSet {
            rebuild()
        }
    }
    
    var selectedCategory: Category?
    
    private var tableStackView: UIStackView!
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    // MARK: - Common init
    private func commonInit() {
        self.tableStackView = UIStackView()
        self.tableStackView.axis = .vertical
        self.tableStackView.spacing = 24
        self.addSubview(self.tableStackView)
        self.tableStackView.fitSuperviewConstraint()
    }
    
    // MARK: - Internal
    func rebuild() {
        self.tableStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        var currentRow: UIStackView!
        for index in 0 ..< listCategory.count+1 {
            let selectCategoryItem = SelectCategoryItem()
            selectCategoryItem.delegate = self
            if index == listCategory.count {
                selectCategoryItem.category = nil
            } else {
                selectCategoryItem.category = listCategory[index]
            }

            selectCategoryItem.translatesAutoresizingMaskIntoConstraints = false
            if selectCategoryItem.category?.id == selectedCategory?.id && selectCategoryItem.category != nil {
                selectCategoryItem.select()
            } else {
                selectCategoryItem.unselect()
            }
            
            if index % Const.numberOfColumns == 0 {
                currentRow = UIStackView()
                currentRow.spacing = 24
                currentRow.axis = .horizontal
                currentRow.translatesAutoresizingMaskIntoConstraints = false
                self.tableStackView.addArrangedSubview(currentRow)
                
                NSLayoutConstraint.activate([
                    currentRow.leftAnchor.constraint(equalTo: self.tableStackView.leftAnchor, constant: 0),
                    currentRow.rightAnchor.constraint(equalTo: self.tableStackView.rightAnchor, constant: 0),
                    currentRow.heightAnchor.constraint(equalToConstant: 25)
                ])
            }
            
            currentRow.addArrangedSubview(selectCategoryItem)
            NSLayoutConstraint.activate([
                selectCategoryItem.topAnchor.constraint(equalTo: currentRow.topAnchor),
                selectCategoryItem.bottomAnchor.constraint(equalTo: selectCategoryItem.bottomAnchor),
                selectCategoryItem.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 56.0 - CGFloat(Const.numberOfColumns - 1) * 24.0) / CGFloat(Const.numberOfColumns))
            ])
        }
    }
    
    func reload() {
        for row in self.tableStackView.arrangedSubviews {
            for view in row.subviews {
                if let item = view as? SelectCategoryItem {
                    if item.category?.id == selectedCategory?.id && item.category != nil {
                        item.select()
                    } else {
                        item.unselect()
                    }
                }
            }
        }
    }
}

// MARK: - SelectCategoryItemDelegate
extension SelectCategoryView: SelectCategoryItemDelegate {
    func selectCategoryItemDidSelected(_ view: SelectCategoryItem) {
        self.selectedCategory = view.category
        self.reload()
        self.delegate?.selectCategoryView(self, didSelectCategory: view.category)
    }
}
