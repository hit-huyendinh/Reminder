//
//  StatisticsViewController.swift
//  Reminder
//
//  Created by linhnd99 on 29/03/2022.
//

import UIKit

class StatisticsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tabBar: StatisticsTabBar!
    
    private var listTaskVC: ListTaskViewController!
    private var viewModel = StatisticsScreenViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.refresh()
        self.tabBar.reloadContentScrollView()
    }
    
    // MARK: - Config
    private func config() {
        configTabBar()
        configListTaskVC()
    }
    
    private func configTabBar() {
        tabBar.addItem(title: "COMPLETED") { [weak self] in
            self?.completedTabDidTap()
        }
        
        tabBar.addItem(title: "PAST THE DEADLINE") { [weak self] in
            self?.pastTheDeadlineTabDidTap()
        }
        
        tabBar.addItem(title: "STILL GOING") { [weak self] in
            self?.stillGoingTabDidTap()
        }
    }
    
    private func configListTaskVC() {
        listTaskVC = ListTaskViewController()
        listTaskVC.canRemoveReminder = false
        listTaskVC.isShowAddButtonInHeader = false
        
        listTaskVC.dataSource = self
        listTaskVC.delegate = self
        self.contentView.addSubview(listTaskVC.view)
        listTaskVC.view.fitSuperviewConstraint()
        self.addChild(listTaskVC)
    }
    
    // MARK: - Action
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func completedTabDidTap() {
        if self.viewModel.tab == .completed {
            return
        }
        
        self.viewModel.tab = .completed
        listTaskVC.reloadData()
    }
    
    private func pastTheDeadlineTabDidTap() {
        if self.viewModel.tab == .pastTheDeadline {
            return
        }
        
        self.viewModel.tab = .pastTheDeadline
        listTaskVC.reloadData()
    }
    
    private func stillGoingTabDidTap() {
        if self.viewModel.tab == .stillGoing {
            return
        }
        
        self.viewModel.tab = .stillGoing
        listTaskVC.reloadData()
    }
}

// MARK: - ListTaskViewControllerDataSource
extension StatisticsViewController: ListTaskViewControllerDataSource {
    func numberOfCategories(in viewController: ListTaskViewController) -> Int {
        return self.viewModel.numberOfSection()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, numberOfRemindersInSection section: Int) -> Int {
        return self.viewModel.numberOfItem(in: section)
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, categoryAtIndex index: Int) -> Category {
        return self.viewModel.category(at: index)
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, reminderInSection section: Int, atIndex index: Int) -> Reminder {
        return self.viewModel.reminder(section: section, index: index)
    }
}

// MARK: - ListTaskViewControllerDelegate
extension StatisticsViewController: ListTaskViewControllerDelegate {
    func listTaskVC(_ viewController: ListTaskViewController, didSelectAddTaskTo category: Category) {
        // nothing
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didSelectReminderInSection section: Int, atIndex index: Int) {
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.bind(reminderViewModel: ReminderViewModel(reminder: self.viewModel.reminder(section: section, index: index)))
        self.navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didSelectDeleteInSection section: Int, atIndex index: Int) {
        // nothing
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, didChangeCompletedStatus status: Bool, inReminder reminder: Reminder) {
        self.viewModel.setIsCompleted(status, for: reminder)
        self.listTaskVC.reloadData()
    }
}
