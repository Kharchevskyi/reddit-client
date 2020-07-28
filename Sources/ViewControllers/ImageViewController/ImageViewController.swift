//
//  ImageViewController.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine

final class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    private var imageLoader: ImageLoaderType!
    private var viewModel: ImageViewModel!
    private var subscriptions: Set<AnyCancellable> = []
    private var imageURL: URL?
    private var buttonState: ImageViewNode.ButtonState = .idle
    
    // MARK: - Initialisation
    static func initialise(with imageURL: URL) -> ImageViewController {
        let vc = UIStoryboard.main.instantiateViewController(type: ImageViewController.self)
        vc.imageURL = imageURL
        return vc
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageLoader = inject(
            type: ImageLoaderType.self,
            responder: self,
            fallback: ImageLoader.shared
        )
        self.viewModel = ImageViewModel()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.action = .loadImage(imageURL)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButton?.layer.borderWidth = 2
    }

    @IBAction func tapButtonAction(_ sender: Any) {
        switch buttonState {
        case .close:
            dismiss(animated: true, completion: nil)
        case .retry:
            viewModel.action = .loadImage(imageURL)
        case .save:
            saveImage()
        case .saved:
            dismiss(animated: true, completion: nil)
        case .oppenSettings:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsUrl) else {
                return
            }

            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        case .idle:
            break
        }
    }
    
    private func saveImage() {
        guard let imageToSave = imageView?.image else {
            viewModel.action = .loadImage(imageURL)
            return
        }
        viewModel.action = .saveImage(imageToSave)
    }
}
 
extension ImageViewController {
    private func setupViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard let node = value?.node else { return }
                self?.updateUI(with: node)
            })
            .store(in: &subscriptions)
    }
    
    private func updateUI(with node: ImageViewNode) {
        actionButton?.setAttributedTitle(node.buttonState.title, for: .normal)
        actionButton?.isEnabled = node.buttonState.isEnabled
        actionButton?.layer.borderColor = node.buttonState.color.cgColor
        buttonState = node.buttonState
        
        activityIndicator?.isHidden = !node.isLoading
        node.isLoading
            ? activityIndicator?.startAnimating()
            : activityIndicator?.stopAnimating()
        
        imageView?.image = node.image
        messageLabel?.attributedText = node.messageTitle
    }
}
