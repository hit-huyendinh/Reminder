//
//  SelectCategoryCell.swift
//  Reminder
//
//  Created by linzsc on 26/02/2022.
//

import UIKit

final class SelectCategoryCell: UICollectionViewCell {
    @IBOutlet private weak var newButtonView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var selectedImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    func bind(viewModel: CategoryViewModel?, isSelected: Bool? = nil) {
        guard let viewModel = viewModel, let isSelected = isSelected else {
            selectedImageView.isHidden = true
            containerView.isHidden = true
            newButtonView.isHidden = false
            return
        }

        containerView.isHidden = false
        selectedImageView.isHidden = !isSelected
        newButtonView.isHidden = true

        titleLabel.text = viewModel.name()
        containerView.backgroundColor = viewModel.color()
    }

}
