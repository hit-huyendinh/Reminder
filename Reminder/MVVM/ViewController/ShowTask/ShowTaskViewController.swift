//
//  ShowTaskViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import UIKit

final class ShowTaskViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var emptyImageView: UIImageView!
    @IBOutlet private weak var emptyTitleLabel: UILabel!
    @IBOutlet private weak var emptySubtitleLabel: UILabel!
    
    private var listTaskVC: ListTaskViewController!
    private var viewModel = CategoriesViewModel()
    private var date: Date?
    
    // MARK: - Init
    init(isTodayFiltered: Bool = false) {
        super.init(nibName: nil, bundle: Bundle.main)
        self.date = isTodayFiltered ? Date() : nil
        self.viewModel = CategoriesViewModel(date: self.date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.date != nil {
            self.viewModel = CategoriesViewModel(date: Date())
        }

        self.reloadData()
    }
    
    // MARK: - Config
    private func config() {
        configListTaskVC()
        titleLabel.text = viewModel.date == nil ? "All task" : "Today"
        self.emptyImageView.image = UIImage(named: viewModel.date == nil ? "ic_no_all_reminder" : "ic_no_reminder_today")
        self.emptyTitleLabel.text = viewModel.date == nil ? "You don’t have any schedule today." : "Make something happen from planning the day ahead."
        self.emptySubtitleLabel.text = viewModel.date == nil ? "Tap + to create new to-do." : "Rest is as important as working hard."
    }
    
    private func configListTaskVC() {
        listTaskVC = ListTaskViewController()
        listTaskVC.dataSource = self
        listTaskVC.delegate = self
        
        contentView.addSubview(listTaskVC.view)
        listTaskVC.view.fitSuperviewConstraint()
        listTaskVC.view.backgroundColor = .clear
        self.addChild(listTaskVC)
    }
    
    // MARK: - Action
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper
    private func reloadData() {
        self.listTaskVC.reloadData()
        emptyView.isHidden = self.viewModel.numberOfTasks() != 0
    }
}

// MARK: - ListTaskViewControllerDataSource
extension ShowTaskViewController: ListTaskViewControllerDataSource {
    func numberOfCategories(in viewController: ListTaskViewController) -> Int {
        return self.viewModel.numberOfCategories()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, numberOfRemindersInSection section: Int) -> Int {
        return self.viewModel.categoryAt(index: section).numberOfReminders()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, categoryAtIndex index: Int) -> Category {
        return self.viewModel.categoryAt(index: index).category
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, reminderInSection section: Int, atIndex index: Int) -> Reminder {
        return self.viewModel.categoryAt(index: section).reminderAt(index: index).reminder
    }
}

// MARK: - ListTaskViewControllerDelegate
extension ShowTaskViewController: ListTaskViewControllerDelegate {
    func listTaskVC(_ viewController: ListTaskViewController, didSelectReminderInSection section: Int, atIndex index: Int) {
        let taskDetailViewController = TaskDetailViewController()
        let reminderVM = self.viewModel.categoryAt(index: section).reminderAt(index: index)
        taskDetailViewController.bind(reminderViewModel: reminderVM)
        self.navigationController?.pushViewController(taskDetailViewController, animated: true)
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didSelectDeleteInSection section: Int, atIndex index: Int) {
        self.viewModel.deleteTask(categoryIndex: section, taskIndex: index)
        self.viewModel.refresh()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didChangeCompletedStatus status: Bool, inReminder reminder: Reminder) {
        self.viewModel.setIsCompleted(status, for: reminder)
        self.viewModel.refresh()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didSelectAddTaskTo category: Category) {
        let addTaskViewController = AddTaskViewController()
        addTaskViewController.categoryId = category.id
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
}
