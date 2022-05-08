//
//  TaskDetailViewController.swift
//  Reminder
//
//  Created by linzsc on 26/02/2022.
//

import UIKit

class TaskDetailViewController: UIViewController {
    @IBOutlet private weak var containerReminderDetailView: UIView!
    @IBOutlet private weak var saveButton: TapableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var reminderDetailView: ReminderDetailView!
    private var reminderViewModel: ReminderViewModel!

    // MARK: - Override touches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    // MARK: - Config
    private func config() {
        reminderDetailView = ReminderDetailView.loadView()
        reminderDetailView.delegate = self
        self.scrollView.subviews.first?.addSubview(reminderDetailView)
        reminderDetailView.fitSuperviewConstraint()
        reminderDetailView.bindData(viewModel: self.reminderViewModel)

        titleLabel.text = self.reminderViewModel.reminder.categoryId == "" ? "Add Task" : "Details"
    }

    // MARK: - Action
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure to delete this reminder", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.reminderViewModel = ReminderViewModel(reminder: self.reminderDetailView.getReminder())
            self.reminderViewModel.deleteInDB()
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func saveButtonDidTap(_ sender: Any) {
        self.reminderViewModel = ReminderViewModel(reminder: self.reminderDetailView.getReminder())
        self.reminderViewModel.saveToDB()
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper
    func bind(reminderViewModel: ReminderViewModel?) {
        if reminderViewModel == nil {
            self.reminderViewModel = ReminderViewModel(reminder: Reminder(name: "", categoryId: ""))
        } else {
            self.reminderViewModel = reminderViewModel!
        }

        if self.isViewLoaded {
            reminderDetailView.bindData(viewModel: self.reminderViewModel)
            titleLabel.text = self.reminderViewModel.reminder.categoryId == "" ? "Add Task" : "Details"
        }
    }
}

// MARK: - ReminderDetailViewDelegate
extension TaskDetailViewController: ReminderDetailViewDelegate {
    func reminderDetailViewNeedCreateNewCategory(_ view: ReminderDetailView) {
        let categoryDetailVC = CategoryDetailViewController()
        categoryDetailVC.delegate = self
        self.present(categoryDetailVC, animated: true, completion: nil)
    }
    
    func reminderDetailView(_ view: ReminderDetailView, needSelectTime currentSelectedDate: Date) {
        let datePickerView = DatePickerView()
        datePickerView.pickerMode = .time
        datePickerView.date = currentSelectedDate
        datePickerView.delegate = reminderDetailView
        datePickerView.modalPresentationStyle = .overFullScreen
        datePickerView.modalTransitionStyle = .coverVertical
        self.present(datePickerView, animated: true, completion: nil)
    }
    
    func reminderDetailView(_ view: ReminderDetailView, needSelectDate currentSelectedDate: Date) {
        let datePickerView = DatePickerView()
        datePickerView.pickerMode = .date
        datePickerView.date = currentSelectedDate
        datePickerView.delegate = reminderDetailView
        datePickerView.modalPresentationStyle = .overFullScreen
        datePickerView.modalTransitionStyle = .coverVertical
        self.present(datePickerView, animated: true, completion: nil)
    }
    
    func reminderDetailView(_ view: ReminderDetailView, didChangeText text: String, category: Category?) {
        let isValid = !text.isEmpty && category != nil
        saveButton.isUserInteractionEnabled = !isValid
        saveButton.backgroundColor = !isValid ? .lightGray : UIColor(rgb: 0x575FCC)
    }
}

// MARK: - CategoryDetailDelegate
extension TaskDetailViewController: CategoryDetailDelegate {
    func categoryDetail(_ viewController: CategoryDetailViewController, didSaveCategory category: Category) {
        self.reminderDetailView.reloadListCategories()
    }
}
