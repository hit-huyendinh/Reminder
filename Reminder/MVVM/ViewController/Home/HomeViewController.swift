//
//  HomeViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit

enum HomeScreenTab {
    case home, calendar
}

private struct Const {
    static let colorSelected: Int = 0x008081
    static let colorUnselected: Int = 0xACB5B5
}

final class HomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var containerTabBarView: UIView!
    @IBOutlet private weak var addButton: TapableView!
    @IBOutlet private weak var homeTabLabel: UILabel!
    @IBOutlet private weak var calendarTabLabel: UILabel!
    @IBOutlet private weak var homeTabImageView: UIImageView!
    @IBOutlet private weak var calendarTabImageView: UIImageView!
    @IBOutlet private weak var topContainerTabBarViewConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    private var homeTabVC: HomeTabViewController!
    private var calendarTabVC: CalendarTabViewController!
    private var currentVC: UIViewController!
    private var currentTab: HomeScreenTab!
    
    // MARK: - Override touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        homeTabVC = HomeTabViewController()
        homeTabVC.delegate = self
        
        calendarTabVC = CalendarTabViewController()
        calendarTabVC.bind(date: Date())
        
        self.selectTab(.home)
    }

    // MARK: - Action
    @IBAction func homeTabDidTap(_ sender: Any) {
        self.selectTab(.home)
    }
    
    @IBAction func calendarTabDidTap(_ sender: Any) {
        self.selectTab(.calendar)
    }
    
    @IBAction func addButtonDidTap(_ sender: Any) {
        let addTaskViewController = AddTaskViewController()
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    // MARK: - Helper
    private func selectTab(_ tab: HomeScreenTab) {
        if self.currentTab == tab {
            return
        }
        
        if self.currentVC != nil {
            self.currentVC.view.removeFromSuperview()
            self.currentVC.removeFromParent()
        }
        
        self.currentTab = tab
        switch tab {
        case .home:
            homeTabLabel.textColor = UIColor(rgb: Const.colorSelected)
            calendarTabLabel.textColor = UIColor(rgb: Const.colorUnselected)
            homeTabImageView.image = UIImage(named: "ic_home_selected")
            calendarTabImageView.image = UIImage(named: "ic_calendar_unselected")
            self.currentVC = homeTabVC
        case .calendar:
            homeTabLabel.textColor = UIColor(rgb: Const.colorUnselected)
            calendarTabLabel.textColor = UIColor(rgb: Const.colorSelected)
            homeTabImageView.image = UIImage(named: "ic_home_unselected")
            calendarTabImageView.image = UIImage(named: "ic_calendar_selected")
            self.currentVC = calendarTabVC
        }
        
        self.contentView.addSubview(self.currentVC.view)
        self.currentVC.view.fitSuperviewConstraint()
        self.addChild(self.currentVC)
    }
}

// MARK: - HomeTabViewControllerDelegate
extension HomeViewController: HomeTabViewControllerDelegate {
    func homeTabNeedRouteToAllTaskScreen(_ viewController: HomeTabViewController) {
        let showTaskVC = ShowTaskViewController()
        self.navigationController?.pushViewController(showTaskVC, animated: true)
    }
    
    func homeTabNeedRouteToTodayTaskScreen(_ viewController: HomeTabViewController) {
        let showTaskVC = ShowTaskViewController(isTodayFiltered: true)
        self.navigationController?.pushViewController(showTaskVC, animated: true)
    }
    
    func homeTabNeedRouteToReminder(_ viewController: HomeTabViewController, by category: Category) {
        let reminderByCategoryVC = ReminderByCategoryViewController()
        reminderByCategoryVC.bindData(category: category)
        self.navigationController?.pushViewController(reminderByCategoryVC, animated: true)
    }
    
    func homeTabNeedRouteToAddCategory(_ viewController: HomeTabViewController) {
        let categoryDetailVC = CategoryDetailViewController()
        categoryDetailVC.delegate = self
        self.present(categoryDetailVC, animated: true, completion: nil)
    }
    
    func homeTabNeedShowTabBar(_ viewController: HomeTabViewController) {
        containerTabBarView.isHidden = false
        addButton.isHidden = false
        topContainerTabBarViewConstraint.constant = 0
    }
    
    func homeTabNeedHideTabBar(_ viewController: HomeTabViewController) {
        containerTabBarView.isHidden = true
        addButton.isHidden = true
        topContainerTabBarViewConstraint.constant = -containerTabBarView.frame.height
    }
    
    func homeTab(_ viewController: HomeTabViewController, needCreateNewReminderTo category: Category) {
        let addTaskViewController = AddTaskViewController()
        addTaskViewController.categoryId = category.id
        self.navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    func homeTab(_ viewController: HomeTabViewController, needShowReminderDetail reminder: Reminder) {
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.bind(reminderViewModel: ReminderViewModel(reminder: reminder))
        self.navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    
    func homeTabNeedRouteToStatistics(_ viewController: HomeTabViewController) {
        let statisticsVC = StatisticsViewController()
        self.navigationController?.pushViewController(statisticsVC, animated: true)
    }
    
    func homeTabNeedRouteToLogin(_ viewController: HomeTabViewController) {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .coverVertical
        self.navigationController?.present(loginVC, animated: true)
    }
    
    func homeTabNeedShowSetting(_ viewController: HomeTabViewController, contentOffsetY: CGFloat) {
        let accountVC = AccountViewController()
        accountVC.delegate = self
        accountVC.topContentViewConstant = contentOffsetY
        accountVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(accountVC, animated: false)
    }
}

// MARK: - CategoryDetailDelegate
extension HomeViewController: CategoryDetailDelegate {
    func categoryDetail(_ viewController: CategoryDetailViewController, didSaveCategory category: Category) {
        homeTabVC.viewModel.refresh()
        homeTabVC.reloadData()
    }
}

// MARK: - AccountViewControllerDelegate
extension HomeViewController: AccountViewControllerDelegate {
    func accountViewControllerDidEndPullData(_ viewController: AccountViewController) {
        homeTabVC.viewModel.refresh()
        homeTabVC.reloadData()
    }
}
