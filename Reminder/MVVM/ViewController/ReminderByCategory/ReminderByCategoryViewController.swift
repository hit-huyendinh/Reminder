//
//  ReminderByCategoryViewController.swift
//  Reminder
//
//  Created by linhnd99 on 09/03/2022.
//

import UIKit

private struct Const {
    static let heightCell: CGFloat = 74
}

final class ReminderByCategoryViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var createReminderButton: TapableView!
    @IBOutlet private weak var optionButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var categoryImageView: UIImageView!
    
    private var viewModel: ReminderByCategoryViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
    }
    
    // MARK: - Config
    private func config() {
        tableView.registerCell(type: TaskCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.bottom = self.view.bounds.height - createReminderButton.frame.minY + 15
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = self.view.bounds.height - createReminderButton.frame.minY + 15
    }
    
    // MARK: - Action
    @IBAction func optionButtonDidTap(_ sender: Any) {
        let optionDialog = OptionDialog()
        optionDialog.addAction(title: "Name & Appearance", image: UIImage(named: "ic_pencil")!) { [weak self] in
            self?.editCategoryButtonDidTap()
        }
        
        optionDialog.addAction(title: self.viewModel.isShowCompleted ? "Hide Completed" : "Show Completed", image: UIImage(named: "ic_eye")!) { [weak self] in
            self?.showCompletedButtonDidTap()
        }
        
        optionDialog.addAction(title: "Delete list", image: UIImage(named: "ic_trash")!, color: UIColor(rgb: 0xFF3B30)) { [weak self] in
            self?.deleteCategoryButtonDidTap()
        }
        
        let rect = optionButton.superview!.convert(optionButton.frame, to: self.view)
        optionDialog.layoutContentView(top: rect.maxY, right: self.view.bounds.width - rect.maxX)
        
        optionDialog.modalPresentationStyle = .overFullScreen
        optionDialog.modalTransitionStyle = .crossDissolve
        self.present(optionDialog, animated: true, completion: nil)
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createReminderButtonDidTap(_ sender: Any) {
        let addTaskViewController = AddTaskViewController()
        addTaskViewController.categoryId = self.viewModel.category.id
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    private func deleteCategoryButtonDidTap() {
        self.viewModel.removeThisCategory()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editCategoryButtonDidTap() {
        let categoryDetailVC = CategoryDetailViewController()
        categoryDetailVC.delegate = self
        categoryDetailVC.bind(category: viewModel.category)
        self.present(categoryDetailVC, animated: true, completion: nil)
    }
    
    private func showCompletedButtonDidTap() {
        self.viewModel.isShowCompleted = !self.viewModel.isShowCompleted
        self.refreshData()
    }
    
    // MARK: - Helper
    func bindData(category: Category) {
        self.viewModel = ReminderByCategoryViewModel(category: category)
        if self.isViewLoaded {
            self.refreshData()
        }
    }
    
    func refreshData() {
        self.titleLabel.text = self.viewModel.categoryName()
        self.emptyView.isHidden = !self.viewModel.isEmpty()
        self.categoryImageView.image = self.viewModel.categoryImage()
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReminderByCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfReminders(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: TaskCell.self, indexPath: indexPath)!
        cell.delegate = self
        cell.bind(reminderViewModel: self.viewModel.reminder(at: indexPath.row, in: indexPath.section), indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.text = viewModel.titleSection(index: section)
        label.font = Nunito.boldFont(size: 20)
        label.textColor = UIColor(rgb: 0x212121)
        label.sizeToFit()
        label.frame.origin.x = 20
        
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.heightCell
    }
}

// MARK: - TaskCellDelegate
extension ReminderByCategoryViewController: TaskCellDelegate {
    func taskCell(_ cell: TaskCell, didSelectCompleted isCompleted: Bool) {
        self.viewModel.updateCompleted(isCompleted, reminder: cell.viewModel.reminder)
        self.refreshData()
    }
}

// MARK: - CategoryDetailDelegate
extension ReminderByCategoryViewController: CategoryDetailDelegate {
    func categoryDetail(_ viewController: CategoryDetailViewController, didSaveCategory category: Category) {
        self.viewModel.category = category
        self.refreshData()
    }
}
