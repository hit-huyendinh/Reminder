//
//  PHAssetExtension.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 21/02/2022.
//
import Foundation
import Photos
import UIKit
import MobileCoreServices

extension PHAsset {
    func thumbnail(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true

        var result: UIImage?
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option) {(image, _) in
            result = image
        }
        
        return result
    }
    
    func originalFileName() -> String? {
        if let resource = PHAssetResource.assetResources(for: self).first {
            return resource.originalFilename
        }
        
        return nil
    }
    
    static func fromLocalIdentifier(_ id: String) -> PHAsset? {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
        return result.firstObject
    }

    func isGifType() -> Bool {
        if let identifier = self.value(forKey: "uniformTypeIdentifier") as? String {
             if identifier == kUTTypeGIF as String {
               return true
             }
        }
        return false
    }

    func getImageURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        if self.mediaType != .image {
            completionHandler(nil)
        }
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
            completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
        })
    }
    
    func getVideoURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        if self.mediaType != .video {
            completionHandler(nil)
        }
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            print(asset)
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                completionHandler(localVideoUrl)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func getVideoAsset(completionHandler: @escaping ((_ asset: AVAsset?) -> Void)) {
        if self.mediaType != .video {
            completionHandler(nil)
        }
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            completionHandler(asset)
        })
    }
}
