//
//  TaskCell.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 23/02/2022.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func taskCell(_ cell: TaskCell, didSelectCompleted isCompleted: Bool)
}

final class TaskCell: UITableViewCell {
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectedCircleImageView: UIImageView!
        
    weak var delegate: TaskCellDelegate?
    var viewModel: ReminderViewModel!
    var indexPath: IndexPath!
    
    func bind(reminderViewModel: ReminderViewModel, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.viewModel = reminderViewModel
        self.titleLabel.text = reminderViewModel.name()
        
        subtitleLabel.text = reminderViewModel.subtitleString()
        subtitleLabel.textColor = reminderViewModel.isLater() ? UIColor(rgb: 0xFF5151) : UIColor(rgb: 0xACB5B5)
        
        selectedCircleImageView.image = UIImage(named: reminderViewModel.isCompleted() ? "ic_circle_selected" : "ic_circle_unselected")
    }
    
    // MARK: - Action
    @IBAction func selectedButtonDidTap(_ sender: Any) {
        delegate?.taskCell(self, didSelectCompleted: !self.viewModel.isCompleted())
    }
}
