//
//  CalendarTaskCell.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 13/03/2022.
//

import UIKit

class CalendarTaskCell: UITableViewCell {
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func bind(viewModel: CalendarTaskItemViewModel) {
        colorView.backgroundColor = viewModel.color()
        timeLabel.text = viewModel.timeString()
        titleLabel.text = viewModel.name()
    }
}
