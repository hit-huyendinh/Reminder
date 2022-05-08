//
//  ReminderDetailView.swift
//  Reminder
//
//  Created by linzsc on 25/02/2022.
//

import UIKit

private struct Const {
    static let topContainerSelectCategoryViewConstant: CGFloat = 28
    static let selectReminderRepeatViewTag: Int = 200
    static let selectRemindingTimeViewTag: Int = 100
}

protocol ReminderDetailViewDelegate: AnyObject {
    func reminderDetailView(_ view: ReminderDetailView, needSelectDate currentSelectedDate: Date)
    func reminderDetailView(_ view: ReminderDetailView, needSelectTime currentSelectedDate: Date)
    func reminderDetailView(_ view: ReminderDetailView, didChangeText text: String, category: Category?)
    func reminderDetailViewNeedCreateNewCategory(_ view: ReminderDetailView)
}

class ReminderDetailView: UIView {
    static func loadView() -> ReminderDetailView {
        let view = ReminderDetailView.loadView(fromNib: "ReminderDetailView")!
        view.config()
        return view
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var reminderTimeLabel: UILabel!
    @IBOutlet private weak var repeatLabel: UILabel!
    @IBOutlet private weak var endRepeatLabel: UILabel!
    @IBOutlet private weak var containerSelectEndRepeatView: UIView!
    @IBOutlet private weak var listCategoryView: SelectCategoryView!
    @IBOutlet private weak var topContainerSelectCategoryViewConstraint: NSLayoutConstraint!
    
    weak var delegate: ReminderDetailViewDelegate?
    private var viewModel: ReminderViewModel!
    private var categoriesViewModel = CategoriesViewModel()
    private var listRemindingTime: [RemindingTime]!
    private var listRemindingRepeat: [ReminderRepeat]!

    // MARK: - Override touches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.endEditing(true)
    }

    // MARK: - Config
    func config() {
        configListCategoryView()
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        nameTextField.rightViewMode = .always
        nameTextField.delegate = self
    }
    
    private func configListCategoryView() {
        listCategoryView.listCategory = categoriesViewModel.categories
        listCategoryView.delegate = self
    }

    // MARK: - Action
    @IBAction func selectDateButtonDidTap(_ sender: Any) {
        delegate?.reminderDetailView(self, needSelectDate: self.viewModel.reminder.targetTime)
    }

    @IBAction func selectTimeButtonDidTap(_ sender: Any) {
        delegate?.reminderDetailView(self, needSelectTime: self.viewModel.reminder.targetTime)
    }

    @IBAction func selectReminderTimeButtonDidTap(_ sender: Any) {
        SelectItemPopup.show(title: "Reminder", delegate: self, tag: Const.selectRemindingTimeViewTag)
    }

    @IBAction func selectRepeatButtonDidTap(_ sender: Any) {
        SelectItemPopup.show(title: "Repeat", delegate: self, tag: Const.selectReminderRepeatViewTag)
    }

    @IBAction func selectEndRepeatButtonDidTap(_ sender: Any) {
        SelectRemindingEndRepeatView.show(delegate: self)
    }

    // MARK: - Helper
    func bindData(viewModel: ReminderViewModel? = nil) {
        if let viewModel = viewModel {
            self.viewModel = viewModel
        } else {
            self.viewModel = ReminderViewModel(reminder: Reminder(name: "", categoryId: categoriesViewModel.categoryAt(index: 0).category.id))
        }

        nameTextField.text = self.viewModel.name()
        dateLabel.text = self.viewModel.targetDateString()
        timeLabel.text = self.viewModel.targetTimeString()
        reminderTimeLabel.text = self.viewModel.reminderTimeString()
        repeatLabel.text = self.viewModel.remindingRepeatString()
        endRepeatLabel.text = self.viewModel.remindingEndRepeatString()
        listCategoryView.selectedCategory = categoriesViewModel.categories.first(where: {$0.id == self.viewModel.reminder.categoryId})
        listCategoryView.reload()
        
        UIView.animate(withDuration: 0.25) {
            if self.viewModel.reminder.remindingRepeat != .never {
                self.endRepeatLabel.text = self.viewModel.remindingEndRepeatString()
                self.containerSelectEndRepeatView.alpha = 1
                self.topContainerSelectCategoryViewConstraint.constant = Const.topContainerSelectCategoryViewConstant
            } else {
                self.containerSelectEndRepeatView.alpha = 0
                self.topContainerSelectCategoryViewConstraint.constant = -self.containerSelectEndRepeatView.bounds.height
            }

            self.layoutIfNeeded()
        }

        self.loadSelectingData()
    }

    private func loadSelectingData() {
        listRemindingTime = [
            RemindingTime.never,
            RemindingTime.on(viewModel.reminder.targetTime),
            RemindingTime.before5Min,
            RemindingTime.before30Min,
            RemindingTime.before1Hour
        ]

        listRemindingRepeat = [
            ReminderRepeat.never,
            ReminderRepeat.daily,
            ReminderRepeat.weekly,
            ReminderRepeat.monthly,
            ReminderRepeat.yearly
        ]
    }
    
    func getReminder() -> Reminder {
        return self.viewModel.reminder
    }
    
    func reloadListCategories() {
        self.categoriesViewModel.refresh()
        self.listCategoryView.listCategory = self.categoriesViewModel.categories
        self.listCategoryView.rebuild()
    }
}

// MARK: - SelectItemPopupDelegate
extension ReminderDetailView: SelectItemPopupDelegate {
    func selectItemPopup(_ view: SelectItemPopup, didSelect index: Int) {
        if view.tag == Const.selectReminderRepeatViewTag {
            self.viewModel.reminder.remindingRepeat = listRemindingRepeat[index]
        } else {
            self.viewModel.reminder.remindingTime = listRemindingTime[index]
        }
        
        self.bindData(viewModel: self.viewModel)
    }

    func selectItemPopupGetText(_ view: SelectItemPopup, index: Int) -> String {
        if view.tag == Const.selectReminderRepeatViewTag {
            return listRemindingRepeat[index].string
        }

        return listRemindingTime[index].rawValue == RemindingTime.on(viewModel.reminder.targetTime).rawValue ? "On time" : listRemindingTime[index].string
    }

    func selectItemPopupGetNumberItems(_ view: SelectItemPopup) -> Int {
        if view.tag == Const.selectReminderRepeatViewTag {
            return listRemindingRepeat.count
        }

        return listRemindingTime.count
    }

    func selectItemPopupGetSelectedIndex(_ view: SelectItemPopup) -> Int {
        if view.tag == Const.selectReminderRepeatViewTag {
            return listRemindingRepeat.firstIndex(where: {$0.rawValue == self.viewModel.reminder.remindingRepeat.rawValue}) ?? 0
        }

        return listRemindingTime.firstIndex(where: {$0.rawValue == self.viewModel.reminder.remindingTime.rawValue}) ?? 0
    }
}

// MARK: - DatePickerViewDelegate
extension ReminderDetailView: DatePickerViewDelegate {
    func datePickerView(_ view: DatePickerView, didSelectDate date: Date) {
        self.viewModel.reminder.targetTime = date
        self.bindData(viewModel: self.viewModel)
    }
}

// MARK: - SelectRemindingEndRepeatViewDelegate
extension ReminderDetailView: SelectRemindingEndRepeatViewDelegate {
    func selectRemindingEndRepeatNeedGetSelectedRemindingEndRepeat(_ view: SelectRemindingEndRepeatView) -> ReminderEndRepeat {
        return self.viewModel.reminder.remindingEndRepeat ?? .forever
    }
    
    func selectRemindingEndRepeat(_ view: SelectRemindingEndRepeatView, didSelectRemindingEndRepeat value: ReminderEndRepeat) {
        self.viewModel.reminder.remindingEndRepeat = value
        self.endRepeatLabel.text = self.viewModel.remindingEndRepeatString()
    }
}

// MARK: - UITextFieldDelegate
extension ReminderDetailView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string).trim()
            self.viewModel.reminder.name = updatedText
            delegate?.reminderDetailView(self, didChangeText: updatedText, category: self.listCategoryView.selectedCategory)
        }
        
        return true
    }
}

// MARK: - SelectCategoryViewDelegate
extension ReminderDetailView: SelectCategoryViewDelegate {
    func selectCategoryView(_ view: SelectCategoryView, didSelectCategory category: Category?) {
        if category == nil {
            self.delegate?.reminderDetailViewNeedCreateNewCategory(self)
        } else {
            self.viewModel.reminder.categoryId = category!.id
            self.delegate?.reminderDetailView(self, didChangeText: nameTextField.text?.trim() ?? "", category: category)
        }
    }
}
