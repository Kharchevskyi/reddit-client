//
//  ImageViewModelTest.swift
//  RedditClientTests
//
//  Created by Anton Kharchevskyi on 29/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Combine
import XCTest
@testable import RedditClient

struct ImageLoaderMock: ImageLoaderType {
    var mockedResult: (() -> (UIImage?))?
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        Just<UIImage?>(mockedResult?())
            .eraseToAnyPublisher()
    }
}

struct GalleryServiceMock: GalleryServiceType {
    func saveImage(with image: UIImage, completion: GalleryServiceCompletion?) {
        
    }
}

class ImageViewModelTest: XCTestCase {
    var sut: ImageViewModel!
    private var subscriptions: Set<AnyCancellable> = []
    private var imageLoader = ImageLoaderMock()
    
    override func setUp() {
        sut = ImageViewModel(
            imageLoader: imageLoader,
            galleryService: GalleryServiceMock()
        )
    }
    
    func test_when_there_is_url_provided() {
        let expIdle = expectation(description: "State should be changed to idle")
        let expLoading = expectation(description: "State should be changed to loading")
        let expError = expectation(description: "State should be changed to error")
        let expLoaded = expectation(description: "State should not be changed to loaded")
        expLoaded.isInverted = true
        
        sut.$state
            .sink(receiveValue: { state in
                switch state! {
                case .idle: expIdle.fulfill()
                case .loading: expLoading.fulfill()
                case .error: expError.fulfill()
                case .loaded: expLoaded.fulfill()
                }
            })
            .store(in: &subscriptions)
        imageLoader.mockedResult = { nil }
        
        sut.action = .loadImage(nil)
        
        wait(for: [expIdle, expLoading, expError, expLoaded], timeout: 1)
    }
}
