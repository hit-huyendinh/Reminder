//
//  CIImageExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import UIKit

extension CIImage {
    func toUIImage() -> UIImage {
           let context: CIContext = CIContext.init(options: nil)
           let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
           let image: UIImage = UIImage.init(cgImage: cgImage)
           return image
    }
}
