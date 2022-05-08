//
//  ListTaskViewController.swift
//  Reminder
//
//  Created by linhnd99 on 28/03/2022.
//

import UIKit

private struct Const {
    static let heightCell: CGFloat = 74
    static let heightHeader: CGFloat = 44
}

protocol ListTaskViewControllerDataSource: AnyObject {
    func numberOfCategories(in viewController: ListTaskViewController) -> Int
    func listTaskVC(_ viewController: ListTaskViewController, numberOfRemindersInSection section: Int) -> Int
    func listTaskVC(_ viewController: ListTaskViewController, categoryAtIndex index: Int) -> Category
    func listTaskVC(_ viewController: ListTaskViewController, reminderInSection section: Int, atIndex index: Int) -> Reminder
}

protocol ListTaskViewControllerDelegate: AnyObject {
    func listTaskVC(_ viewController: ListTaskViewController, didSelectAddTaskTo category: Category)
    func listTaskVC(_ viewController: ListTaskViewController, didSelectReminderInSection section: Int, atIndex index: Int)
    func listTaskVC(_ viewController: ListTaskViewController, didSelectDeleteInSection section: Int, atIndex index: Int)
    func listTaskVC(_ viewController: ListTaskViewController, didChangeCompletedStatus status: Bool, inReminder reminder: Reminder)
}

class ListTaskViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    weak var dataSource: ListTaskViewControllerDataSource?
    weak var delegate: ListTaskViewControllerDelegate?
    var canRemoveReminder: Bool = true {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    
    var isShowAddButtonInHeader: Bool = true {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        tableView.registerCell(type: TaskCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        configNotificationCenter()
    }
    
    private func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldKeyboardDidShowNotification(_:)), name: UITextField.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldKeyboardWillHideNotification(_:)), name: UITextField.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard notification
    @objc private func textFieldKeyboardDidShowNotification(_ notification: Notification) {
        if isDisplaying,
           let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            tableView.contentInset.bottom = self.view.safeAreaInsets.bottom + keyboardFrame.cgRectValue.height
        }
    }
    
    @objc private func textFieldKeyboardWillHideNotification(_ notification: Notification) {
        if isDisplaying {
            tableView.contentInset.bottom = self.view.safeAreaInsets.bottom
        }
    }
    
    // MARK: - Helper
    func reloadData() {
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ListTaskViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfCategories(in: self) ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.listTaskVC(self, numberOfRemindersInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let category = dataSource?.listTaskVC(self, categoryAtIndex: section) {
            let headerView = ShowTaskHeaderView(category: category)
            headerView.delegate = self
            headerView.isAddButtonHidden = !isShowAddButtonInHeader
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: TaskCell.self, indexPath: indexPath)!
        cell.delegate = self
        let reminderVM = ReminderViewModel(reminder: dataSource!.listTaskVC(self, reminderInSection: indexPath.section, atIndex: indexPath.row))
        cell.bind(reminderViewModel: reminderVM, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.heightCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.heightHeader
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.canRemoveReminder
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.listTaskVC(self, didSelectDeleteInSection: indexPath.section, atIndex: indexPath.row)
            self.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.listTaskVC(self, didSelectReminderInSection: indexPath.section, atIndex: indexPath.row)
    }
}

// MARK: - TaskCellDelegate
extension ListTaskViewController: TaskCellDelegate {
    func taskCell(_ cell: TaskCell, didSelectCompleted isCompleted: Bool) {
        delegate?.listTaskVC(self, didChangeCompletedStatus: isCompleted, inReminder: cell.viewModel.reminder)
        self.tableView.reloadData()
    }
}

// MARK: - ShowTaskHeaderViewDelegate
extension ListTaskViewController: ShowTaskHeaderViewDelegate {
    func showTaskHeaderViewDidTapAddButton(_ view: ShowTaskHeaderView, category: Category) {
        delegate?.listTaskVC(self, didSelectAddTaskTo: category)
    }
}
