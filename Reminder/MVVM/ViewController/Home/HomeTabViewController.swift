//
//  HomeTabViewController.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 22/02/2022.
//

import UIKit

private struct Const {
    static let topSearchTextfieldConstant: CGFloat = 10
    static let rightSearchTextfieldConstant: CGFloat = 24
    static let rightCancelSearchButtonConstant: CGFloat = 12
}

class ContentScrollView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.endEditing(true)
    }
}

protocol HomeTabViewControllerDelegate: AnyObject {
    func homeTabNeedRouteToAllTaskScreen(_ viewController: HomeTabViewController)
    func homeTabNeedRouteToTodayTaskScreen(_ viewController: HomeTabViewController)
    func homeTabNeedRouteToReminder(_ viewController: HomeTabViewController, by category: Category)
    func homeTabNeedRouteToAddCategory(_ viewController: HomeTabViewController)
    func homeTabNeedShowTabBar(_ viewController: HomeTabViewController)
    func homeTabNeedHideTabBar(_ viewController: HomeTabViewController)
    func homeTab(_ viewController: HomeTabViewController, needCreateNewReminderTo category: Category)
    func homeTab(_ viewController: HomeTabViewController, needShowReminderDetail reminder: Reminder)
    func homeTabNeedRouteToStatistics(_ viewController: HomeTabViewController)
    func homeTabNeedRouteToLogin(_ viewController: HomeTabViewController)
    func homeTabNeedShowSetting(_ viewController: HomeTabViewController, contentOffsetY: CGFloat)
}

final class HomeTabViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var numberTodayTaskLabel: UILabel!
    @IBOutlet private weak var numberAllTaskLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var myListStackView: UIStackView!
    @IBOutlet private weak var cancelSearchButton: UIButton!
    @IBOutlet private weak var shadowViewInTop: UIView!
    @IBOutlet private weak var accountButton: TapableView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    @IBOutlet private weak var topSearchTextfieldConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightSearchTextfieldConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightCancelSearchButtonConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    weak var delegate: HomeTabViewControllerDelegate?
    var viewModel = CategoriesViewModel()
    var statisticViewModel = StatisticViewModel()
    var categoriesViewModel = CategoriesViewModel()
    
    private lazy var reminderDao: ReminderDao = {
        return DIContainer.shared.resolve(ReminderDao.self)
    }()
    
    private lazy var userContext: UserContext = {
        return DIContainer.shared.resolve(UserContext.self)
    }()
    
    private var listTaskVC: ListTaskViewController!
    private var isSearchDisplaying: Bool = false
    
    // MARK: - Override touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.endEditing(true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        
        self.hideSearchMode(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        configListTaskVC()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChartView.setNeedsDisplay()
    }
    
    // MARK: - Config
    private func config() {
        scrollView.contentInset.bottom = 40
        configSearchTextField()
        configStackView()
        configPieChartView()
        configNotificationCenter()
        subscribeLoginState()
    }
    
    private func configSearchTextField() {
        searchTextField.delegate = self
        searchTextField.leftViewMode = .always
        let imageView = UIImageView(image: UIImage(named: "ic_search"))
        let containerView = UIView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -13),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
        ])
        
        searchTextField.leftView = containerView
    }
    
    private func configStackView() {
        myListStackView.alignment = .center
        myListStackView.spacing = 12
    }
    
    private func configPieChartView() {
        pieChartView.dataSource = self
        pieChartView.subtitle = "Done"
    }
    
    private func configListTaskVC() {
        listTaskVC = ListTaskViewController()
        listTaskVC.dataSource = self
        listTaskVC.delegate = self
        
        listTaskVC.view.isHidden = true
        listTaskVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(listTaskVC.view, belowSubview: self.shadowViewInTop)
        self.addChild(listTaskVC)
        NSLayoutConstraint.activate([
            listTaskVC.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            listTaskVC.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            listTaskVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            listTaskVC.view.topAnchor.constraint(equalTo: self.shadowViewInTop.bottomAnchor),
        ])
    }
    
    private func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldKeyboardWillShowNotification(_:)), name: UITextField.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldKeyboardWillHideNotification(_:)), name: UITextField.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard notification
    @objc private func textFieldKeyboardWillShowNotification(_ notification: Notification) {
        if isDisplaying {
            self.showSearchMode()
            if self.searchTextField.text?.trim().isEmpty == false {
                listTaskVC.view.isHidden = false
                shadowViewInTop.shadowColor = .black
            }
        }
    }
    
    @objc private func textFieldKeyboardWillHideNotification(_ notification: Notification) {
        if isDisplaying, self.searchTextField.text?.isEmpty == true {
            self.hideSearchMode()
            listTaskVC.view.isHidden = true
            shadowViewInTop.shadowColor = .clear
        }
    }
    
    // MARK: - Action
    @IBAction func cancelSearchButtonDidTap(_ sender: Any) {
        self.searchTextField.text = ""
        self.view.endEditing(true)
        delegate?.homeTabNeedShowTabBar(self)
    }
    
    @IBAction func allTaskButtonDidTap(_ sender: Any) {
        delegate?.homeTabNeedRouteToAllTaskScreen(self)
    }
    
    @IBAction func todayButtonDidTap(_ sender: Any) {
        delegate?.homeTabNeedRouteToTodayTaskScreen(self)
    }
    
    @IBAction func statisticsButtonDidTap(_ sender: Any) {
        delegate?.homeTabNeedRouteToStatistics(self)
    }
    
    @IBAction func addCategoryButtonDidTap(_ sender: Any) {
        delegate?.homeTabNeedRouteToAddCategory(self)
    }
    
    @IBAction func accountButtonDidTap(_ sender: Any) {
        if !self.userContext.isLoggedIn() {
            self.delegate?.homeTabNeedRouteToLogin(self)
        } else {
            let rectInView = self.accountButton.superview!.convert(self.accountButton.frame, to: self.view)
            self.delegate?.homeTabNeedShowSetting(self, contentOffsetY: rectInView.maxY + 5)
        }
    }
    
    // MARK: - Helper
    func reloadData() {
        self.viewModel.refresh()
        self.generateMyLists()
        self.loadNumberOfAlltasks()
        self.loadNumberOfTodayTasks()
        
        self.pieChartView.title = "\(statisticViewModel.completedPercent())%"
        self.pieChartView.setNeedsDisplay()
    }
    
    private func generateMyLists() {
        myListStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        for index in 0 ..< self.viewModel.numberOfCategories() {
            let view = MyCategoryView(category: self.viewModel.categories[index])
            view.delegate = self
            view.translatesAutoresizingMaskIntoConstraints = false
            myListStackView.addArrangedSubview(view)
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 60),
                view.leftAnchor.constraint(equalTo: myListStackView.leftAnchor),
                view.rightAnchor.constraint(equalTo: myListStackView.rightAnchor)
            ])
        }
    }
    
    private func loadNumberOfAlltasks() {
        var counter = 0
        self.viewModel.categories.forEach { category in
            counter += self.reminderDao.getReminders(categoryId: category.id).count
        }
        
        numberAllTaskLabel.text = "\(counter) Task\(counter > 1 ? "s" : "")"
    }
    
    private func loadNumberOfTodayTasks() {
        var counter = 0
        self.viewModel.categories.forEach { category in
            counter += self.reminderDao.getReminders(categoryId: category.id, date: Date()).count
        }
        
        numberTodayTaskLabel.text = "\(counter) Task\(counter > 1 ? "s" : "")"
    }
    
    private func showSearchMode() {
        self.isSearchDisplaying = true
        UIView.animate(withDuration: 0.25) {
            self.topSearchTextfieldConstraint.constant = Const.topSearchTextfieldConstant - self.navigationView.frame.height
            self.rightCancelSearchButtonConstraint.constant = Const.rightCancelSearchButtonConstant
            self.rightSearchTextfieldConstraint.constant = Const.rightSearchTextfieldConstant + self.cancelSearchButton.frame.width
            self.navigationView.alpha = 0
            self.cancelSearchButton.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideSearchMode(animated: Bool = true) {
        self.isSearchDisplaying = false
        let block = {
            self.topSearchTextfieldConstraint.constant = Const.topSearchTextfieldConstant
            self.rightCancelSearchButtonConstraint.constant = Const.rightCancelSearchButtonConstant - (self.cancelSearchButton.frame.width + 10)
            self.rightSearchTextfieldConstraint.constant = Const.rightSearchTextfieldConstant
            self.navigationView.alpha = 1
            self.cancelSearchButton.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: block)
        } else {
            block()
        }
    }
    
    private func subscribeLoginState() {
        self.userContext.subscribeLoginState().asObservable().bind { _ in
            self.avatarImageView.image = self.userContext.profileImage
        }.disposed(by: self.disposeBag)
    }
}

// MARK: - UITextFieldDelegate
extension HomeTabViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showSearchMode()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string).trim()
            listTaskVC.view.isHidden = updatedText.isEmpty
            if updatedText.isEmpty {
                delegate?.homeTabNeedShowTabBar(self)
                shadowViewInTop.shadowColor = .clear
                self.viewModel.nameFiltered = nil
            } else {
                delegate?.homeTabNeedHideTabBar(self)
                shadowViewInTop.shadowColor = .black
                self.viewModel.nameFiltered = updatedText
            }
            
            listTaskVC.reloadData()
        }
        
        return true
    }
}

// MARK: - MyCategoryViewDelegate
extension HomeTabViewController: MyCategoryViewDelegate {
    func myCategoryViewDidTap(_ view: MyCategoryView) {
        delegate?.homeTabNeedRouteToReminder(self, by: view.category)
    }
}

// MARK: - PieChartViewDataSource
extension HomeTabViewController: PieChartViewDataSource {
    func pieChartViewNumberOfItems(_ view: PieChartView) -> Int {
        return 3
    }
    
    func pieChartView(_ view: PieChartView, valueAt index: Int) -> Int {
        if index == 0 {
            return statisticViewModel.numberOfCompleted()
        } else if index == 1 {
            return statisticViewModel.numberOfPastDeadline()
        } else {
            return statisticViewModel.numberOfStillOnGoing()
        }
    }
    
    func pieChartView(_ view: PieChartView, colorAt index: Int) -> UIColor {
        return statisticViewModel.color(at: index)
    }
}

// MARK: - ListTaskViewControllerDataSource
extension HomeTabViewController: ListTaskViewControllerDataSource {
    func numberOfCategories(in viewController: ListTaskViewController) -> Int {
        return self.categoriesViewModel.numberOfCategories()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, numberOfRemindersInSection section: Int) -> Int {
        return self.categoriesViewModel.categoryAt(index: section).numberOfReminders()
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, categoryAtIndex index: Int) -> Category {
        return self.categoriesViewModel.categoryAt(index: index).category
    }
    
    func listTaskVC(_ viewController: ListTaskViewController, reminderInSection section: Int, atIndex index: Int) -> Reminder {
        return self.categoriesViewModel.categoryAt(index: section).reminderAt(index: index).reminder
    }
}

// MARK: - ListTaskViewControllerDelegate
extension HomeTabViewController: ListTaskViewControllerDelegate {
    func listTaskVC(_ viewController: ListTaskViewController, didSelectReminderInSection section: Int, atIndex index: Int) {
        delegate?.homeTab(self, needShowReminderDetail: self.categoriesViewModel.categoryAt(index: section).reminderAt(index: index).reminder)
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
        delegate?.homeTab(self, needCreateNewReminderTo: category)
    }
}
