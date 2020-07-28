//
//  ImageViewModel.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 28/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine
 
final class ImageViewModel: ObservableObject {
    // MARK: - Input
    enum Action {
        case idle
        case loadImage(URL?)
        case retry(URL?)
        case saveImage(UIImage)
    }
    @Published var action: Action = .idle
    
    // MARK: - Output
    enum State {
        case idle(ImageViewNode)
        case loading(ImageViewNode)
        case loaded(ImageViewNode)
        case error(ImageViewNode)
        
        var node: ImageViewNode {
            switch self {
            case let .idle(node): return node
            case let .error(node): return node
            case let .loading(node): return node
            case let .loaded(node): return node
            }
        }
    }
    @Published private(set) var state: State!
    
    // MARK: - Implemenetation
    private enum Error: Swift.Error {
        case url, image, saving
        var message: String {
            switch self {
            case .url: return "URL is missing. Try another image"
            case .image: return "Something went wrong"
            case .saving: return "Image can't be saved\nPlease allow access in Settings"
            }
        }
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    private let imageLoader: ImageLoaderType
    private let galleryService: GalleryServiceType
    private var image: UIImage?
    
    init(
        imageLoader: ImageLoaderType = ImageLoader.shared,
        galleryService: GalleryServiceType = GalleryService()
    ) {
        self.imageLoader = imageLoader
        self.galleryService = galleryService
        self.state = .idle(idleNode())
        
        $action.sink(
            receiveValue: { [weak self] action in
                self?.handle(action: action)
            })
            .store(in: &subscriptions)

    }
}

extension ImageViewModel {
    private func update(to newState: State) {
        state = newState
    }
    
    private func handle(action: Action) {
        switch action {
        case .idle: break
        case let .retry(url), let .loadImage(url):
            loadImage(with: url)
        case let .saveImage(image):
            saveImage(with: image)
        }
    }
  
    private func loadImage(with url: URL?) {
        guard let url = url else {
            update(to: .error(errorNode(error: .url)))
            return
        }
        update(to: .loading(loadingNode()))
        
        imageLoader.loadImage(from: url)
            .sink(receiveValue: { [weak self] image in
                guard let self = self else { return }
                self.image = image
                if let image = image {
                    self.update(to: .loaded(self.loadedNode(with: image)))
                } else {
                    self.update(to: .error(self.errorNode(error: .image)))
                }

            })
            .store(in: &subscriptions)
    }
    
    private func saveImage(with image: UIImage) {
        galleryService.saveImage(with: image) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.update(to: .error(self.errorNode(error: .saving)))
            } else {
                self.update(to: .idle(self.idleSavedNode()))
            }
        }
    }
}

extension ImageViewModel {
    private func idleNode() -> ImageViewNode {
        ImageViewNode(
            messageTitle: NSAttributedString(),
            buttonState: .idle,
            isLoading: true,
            image: image
        )
    }
    
    private func errorNode(error: ImageViewModel.Error) -> ImageViewNode {
        let buttonState: ImageViewNode.ButtonState
        switch error {
        case .url: buttonState = .close
        case .image: buttonState = .retry
        case .saving: buttonState = .oppenSettings
        }
        
        return ImageViewNode(
            messageTitle: NSAttributedString(
                string: error.message,
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                    NSAttributedString.Key.foregroundColor: UIColor.red
                ]
            ),
            buttonState: buttonState,
            isLoading: true,
            image: image
        )
    }
    
    private func loadingNode() -> ImageViewNode {
        ImageViewNode(
            messageTitle: NSAttributedString(),
            buttonState: .idle,
            isLoading: true,
            image: image
        )
    }
    
    private func loadedNode(with image: UIImage) -> ImageViewNode {
        ImageViewNode(
            messageTitle: NSAttributedString(),
            buttonState: .save,
            isLoading: false,
            image: image
        )
    }
    
    private func idleSavedNode() -> ImageViewNode {
        ImageViewNode(
            messageTitle: NSAttributedString(string: "Image is saved to Gallery"),
            buttonState: .saved,
            isLoading: true,
            image: image
        )
    }
}

struct ImageViewNode {
    enum ButtonState {
        case idle, save, close, retry, saved, oppenSettings
        
        var title: NSAttributedString {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor: color
            ]
            let title: String
            switch self {
            case .idle, .save: title = "Save"
            case .close: title = "Close"
            case .retry: title = "Retry"
            case .saved: title = "Saved"
            case .oppenSettings: title = "Go to Settings"
            }
            return NSAttributedString(string: title, attributes: attributes)
        }
        
        var isEnabled: Bool {
            guard case .idle = self else { return true }
            return false
        }
        
        var color: UIColor {
            switch self {
            case .idle: return UIColor.appTextColor.withAlphaComponent(0.5)
            case .save, .oppenSettings: return UIColor.appTextColor
            case .close: return UIColor.red
            case .retry: return UIColor.appTextColor.withAlphaComponent(0.9)
            case .saved: return UIColor.darkGray
            }
        }
    }
    let messageTitle: NSAttributedString
    let buttonState: ButtonState
    let isLoading: Bool
    let image: UIImage?
}
 
