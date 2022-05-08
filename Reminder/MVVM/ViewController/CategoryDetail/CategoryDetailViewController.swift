//
//  CategoryDetailViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 10/03/2022.
//

import UIKit

private struct Const {
    static let spacingCell: CGFloat = 16.0
    static let numberOfColumns: CGFloat = 6.0
}

protocol CategoryDetailDelegate: AnyObject {
    func categoryDetail(_ viewController: CategoryDetailViewController, didSaveCategory category: Category)
}

final class CategoryDetailViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var iconCollectionView: UICollectionView!
    @IBOutlet private weak var doneButton: UIButton!
    
    var delegate: CategoryDetailDelegate?
    var viewModel: CategoryViewModel!
    private var categoryIconViewModel = CategoryIconViewModel()
    
    // MARK: - Override touches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.view.endEditing(true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    // MARK: - Config
    private func config() {
        if viewModel == nil {
            viewModel = CategoryViewModel(category: Category(name: "", iconName: categoryIconViewModel.iconName(at: 0)), date: nil)
            viewModel.category.color = categoryIconViewModel.color(at: 0)
            titleLabel.text = "New list"
        } else {
            titleLabel.text = "Edit list"
        }
        
        configTextField()
        configCollectionView()
    }
    
    private func configTextField() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        nameTextField.leftView = view
        nameTextField.leftViewMode = .always
        view.widthAnchor.constraint(equalToConstant: 20).isActive = true
        nameTextField.delegate = self
    }
    
    private func configCollectionView() {
        iconCollectionView.registerCell(type: CategoryIconCell.self)
        iconCollectionView.dataSource = self
        iconCollectionView.delegate = self
        
        iconCollectionView.contentInset.left = 28
        iconCollectionView.contentInset.right = 28
    }
    
    private func loadData() {
        iconImageView.image = viewModel.image()
        nameTextField.text = viewModel.name()
        refreshDoneButton(nameCategory: viewModel.name())
        iconCollectionView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func doneButtonDidTap(_ sender: Any) {
        viewModel.category.name = nameTextField.text!.trim()
        viewModel.saveCategory()
        delegate?.categoryDetail(self, didSaveCategory: viewModel.category)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Internal
    func bind(category: Category) {
        self.viewModel = CategoryViewModel(category: category, date: nil)
        if self.isViewLoaded {
            self.loadData()
        }
    }
    
    // MARK: - Helper
    private func refreshDoneButton(nameCategory: String) {
        doneButton.isUserInteractionEnabled = !nameCategory.isEmpty
        doneButton.setTitleColor(nameCategory.isEmpty ? .lightGray : UIColor(rgb: 0x007AFF), for: .normal)
    }
}

// MARK: - UITextFieldDelegate
extension CategoryDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string).trim()
            self.refreshDoneButton(nameCategory: updatedText)
        }
        
        return true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CategoryDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryIconViewModel.numberOfIcon()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: CategoryIconCell.self, indexPath: indexPath)!
        cell.bind(image: categoryIconViewModel.icon(at: indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        iconImageView.image = categoryIconViewModel.icon(at: indexPath.row)
        viewModel.category.iconName = categoryIconViewModel.iconName(at: indexPath.row)
        viewModel.category.color = categoryIconViewModel.color(at: indexPath.row)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoryDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.spacingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.spacingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = (UIScreen.main.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - Const.spacingCell * (Const.numberOfColumns-1)) / Const.numberOfColumns
        return CGSize(width: size, height: size)
    }
}
