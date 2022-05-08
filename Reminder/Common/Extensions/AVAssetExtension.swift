//
//  AVAssetExtension.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//

import AVFoundation
import UIKit

extension AVAsset {
    var thumbnailImage: UIImage {
        var image = UIImage()
        let targetSize = CGSize(width: 300, height: 300)
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            image = UIImage.init(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            var newSize = CGSize(width: targetSize.width, height: image.size.height / image.size.width * targetSize.height)
            if newSize.height>targetSize.height {
                newSize = CGSize(width: targetSize.width * image.size.width / image.size.height, height: targetSize.height)
            }
            
            image = image.resize(to: newSize)
        } catch {
            print(error.localizedDescription)
        }
        
        return image
    }
    
    var bitrateAudio: Float {
        if let audioTrack = self.tracks(withMediaType: .audio).first {
            return audioTrack.estimatedDataRate
        }
        
        return 0
    }
    
    var bitrateVideo: Float {
        if let videoTrack = self.tracks(withMediaType: .video).first {
            return videoTrack.estimatedDataRate
        }
        
        return 0
    }
}

