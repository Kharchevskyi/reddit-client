//
//  ImageCache.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

protocol ImageCacheType {
    func image(for url: URL) -> UIImage?
    func insert(image: UIImage?, for url: URL)
    func removeImage(for url: URL)
}

final class ImageCache {
    struct Configuration {
        static let `default` = Configuration(count: 100)
        let count: Int
    }
    
    private let lock = NSLock()
    private let countLimit: Int
    private lazy var cache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = countLimit
        return cache
    }()
    
    init(countLimit: Int = 100) {
        self.countLimit = countLimit
    }
}

extension ImageCache: ImageCacheType {
    func image(for url: URL) -> UIImage? {
        defer { lock.unlock() }
        lock.lock()
            
        guard let image = cache.object(forKey: url as AnyObject) as? UIImage else {
            return nil
        }
        return image
    }
    
    func insert(image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        lock.lock(); defer { lock.unlock() }
        cache.setObject(image, forKey: url as AnyObject)
    }
    
    func removeImage(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        cache.removeObject(forKey: url as AnyObject)
    }
}
