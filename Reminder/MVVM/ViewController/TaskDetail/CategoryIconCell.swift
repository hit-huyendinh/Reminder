//
//  CategoryIconCell.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 10/03/2022.
//

import UIKit

class CategoryIconCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!

    func bind(image: UIImage) {
        imageView.image = image
    }
}
