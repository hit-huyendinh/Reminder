//
//  MPMediaItemCollectionExtensions.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import UIKit
import MediaPlayer

extension MPMediaItemCollection {
    var title: String? {
        return self.value(forProperty: MPMediaPlaylistPropertyName) as? String
    }
}
