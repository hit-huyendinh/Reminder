//
//  MPMediaItemExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import Foundation
import MediaPlayer

extension MPMediaItem {
    var pathExtension: String? {
        get {
            let url = self.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
            return url?.pathExtension
        }
    }
}
