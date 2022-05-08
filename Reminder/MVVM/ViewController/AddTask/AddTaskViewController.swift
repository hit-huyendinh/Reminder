//
//  AddTaskViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 01/03/2022.
//

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var setReminderButton: TapableView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    var categoryId: String!
    private var reminderDetailView: ReminderDetailView!
    private lazy var reminderViewModel: ReminderViewModel! = {
        return categoryId == nil ? nil : ReminderViewModel(reminder: Reminder(name: "", categoryId: categoryId))
    }()
    
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
        
        setReminderButton.isUserInteractionEnabled = false
        setReminderButton.backgroundColor = UIColor(rgb: 0x008081)
        setReminderButton.alpha = 0.5
    }

    // MARK: - Action
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setReminderButtonDidTap(_ sender: Any) {
        self.reminderViewModel = ReminderViewModel(reminder: reminderDetailView.getReminder())
        self.reminderViewModel.saveToDB()
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - ReminderDetailViewDelegate
extension AddTaskViewController: ReminderDetailViewDelegate {
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
        setReminderButton.isUserInteractionEnabled = isValid
        setReminderButton.alpha = isValid ? 1 : 0.5
    }
}

// MARK: - CategoryDetailDelegate
extension AddTaskViewController: CategoryDetailDelegate {
    func categoryDetail(_ viewController: CategoryDetailViewController, didSaveCategory category: Category) {
        self.reminderDetailView.reloadListCategories()
    }
}
