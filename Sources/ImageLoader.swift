//
//  ImageLoader.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine

protocol ImageLoaderType {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache: ImageCacheType
    private let session: URLSession
    private let queue = DispatchQueue(
        label: "com.kharchevskyi.RedditClient.ImageLoader.queue",
        qos: .background
    )
    
    init(
        session: URLSession = .shared,
        cache: ImageCacheType = ImageCache()
    ) {
        self.session = session
        self.cache = cache
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        session.dataTaskPublisher(for: url)
            .subscribe(on: queue)
            .map(\.data)
            .map(UIImage.init)
            .catch { _ in Just(nil)}
            .handleEvents(receiveOutput: { [weak self] image in
                self?.cache.insert(image: image, for: url)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
