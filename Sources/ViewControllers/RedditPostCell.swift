//
//  RedditPostCell.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine

final class RedditPostCell: UITableViewCell {
    typealias TapAction = () -> Void
    private enum Constants {
        static let imageWidth: CGFloat = 60
    }
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var postTitleLabel: UILabel!
    @IBOutlet private var postCommentsLabel: UILabel!
    @IBOutlet private var postAuthorLabel: UILabel!
    private var onActionTap: TapAction?
    private var cancellable: AnyCancellable?

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.bounds.width / 2
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil
        postTitleLabel.text = nil
        postCommentsLabel.text = nil
        postAuthorLabel.text = nil
        cancellable?.cancel()
    }
    
    @objc private func onImageTap(_ sender: UIView) {
         onActionTap?()
    }
}

extension RedditPostCell {
    func with(post: ReditPostViewNode) -> RedditPostCell {
        setupImageView(with: post)
        postTitleLabel.text = post.post.title
        postCommentsLabel.text = String(post.post.numberOfComments)
        postAuthorLabel.text = post.post.author
        layoutIfNeeded()
        return self
    }
    
    func onAction(_ tap: TapAction?) -> RedditPostCell {
        onActionTap = tap
        return self
    }
    
    private func setupImageView(with post: ReditPostViewNode) {
        if let thumbnailURL = post.post.thumbnail {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(onImageTap)
            )
            loadImage(for: thumbnailURL)
            thumbnailImageView.addGestureRecognizer(gesture)
            thumbnailImageView.isUserInteractionEnabled = true
            thumbnailImageView.backgroundColor = .white
        } else {
            thumbnailImageView.backgroundColor = .gray
            thumbnailImageView.isUserInteractionEnabled = false
        }
    }
    
    private func loadImage(for url: URL) {
        cancellable = ImageLoader.shared
            .loadImage(from: url)
            .sink(receiveValue: { [weak self] image in
                self?.thumbnailImageView.image = image
            })
    }
}
