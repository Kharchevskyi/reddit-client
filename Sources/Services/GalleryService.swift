//
//  GalleryService.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 28/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

protocol GalleryServiceType {
    func saveImage(with image: UIImage, completion: GalleryServiceCompletion?)
}

typealias GalleryServiceCompletion = (Error?) -> ()

final class GalleryService: NSObject, GalleryServiceType {
    private var onComplete: GalleryServiceCompletion?
    
    func saveImage(with image: UIImage, completion: GalleryServiceCompletion?) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(didFinishSaving(image:error:contextInfo:)),
            nil
        )
        
        onComplete = completion
    }
     
    @objc private func didFinishSaving(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        onComplete?(error)
    }
}
