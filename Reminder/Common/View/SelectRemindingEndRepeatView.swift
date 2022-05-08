//
//  SelectRemindingEndRepeatView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 02/03/2022.
//

import UIKit

protocol SelectRemindingEndRepeatViewDelegate: AnyObject {
    func selectRemindingEndRepeatNeedGetSelectedRemindingEndRepeat(_ view: SelectRemindingEndRepeatView) -> ReminderEndRepeat
    func selectRemindingEndRepeat(_ view: SelectRemindingEndRepeatView, didSelectRemindingEndRepeat value: ReminderEndRepeat)
}

class SelectRemindingEndRepeatView: UIView {
    static func show(delegate: SelectRemindingEndRepeatViewDelegate?) {
        let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})!

        let view = SelectRemindingEndRepeatView.loadView(fromNib: "SelectRemindingEndRepeatView")!
        view.delegate = delegate
        view.config()

        view.alpha = 0
        window.addSubview(view)
        view.fitSuperviewConstraint()
        view.superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            view.alpha = 1
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var selectedRepeatForeverImageView: UIImageView!
    @IBOutlet private weak var selectedEndRepeatDateImageView: UIImageView!
    
    weak var delegate: SelectRemindingEndRepeatViewDelegate?
    
    // MARK: - Config
    private func config() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap))
        backgroundView.addGestureRecognizer(tapGesture)
        
        setSelected(remindingEndRepeat: delegate?.selectRemindingEndRepeatNeedGetSelectedRemindingEndRepeat(self) ?? .forever)
    }
    
    // MARK: - Action
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func repeatForeverButtonDidTap(_ sender: Any) {
        setSelected(remindingEndRepeat: .forever)
    }
    
    @IBAction func endRepeatDateButtonDidTap(_ sender: Any) {
        setSelected(remindingEndRepeat: .on(Date()))
    }
    
    @objc private func backgroundViewDidTap() {
        self.dismiss()
    }
    
    @IBAction func datePickerDidChangedValue(_ sender: Any) {
        delegate?.selectRemindingEndRepeat(self, didSelectRemindingEndRepeat: .on(datePicker.date))
    }
    
    // MARK: - Helper
    private func setSelected(remindingEndRepeat: ReminderEndRepeat) {
        switch remindingEndRepeat {
        case .forever:
            selectedRepeatForeverImageView.image = UIImage(named: "ic_ratio_selected" )
            selectedEndRepeatDateImageView.image = UIImage(named: "ic_ratio_unselected")
            datePicker.isHidden = true
        case .on(let date):
            selectedRepeatForeverImageView.image = UIImage(named: "ic_ratio_unselected")
            selectedEndRepeatDateImageView.image = UIImage(named: "ic_ratio_selected")
            datePicker.isHidden = false
            datePicker.date = date
        }
        
        delegate?.selectRemindingEndRepeat(self, didSelectRemindingEndRepeat: remindingEndRepeat)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
