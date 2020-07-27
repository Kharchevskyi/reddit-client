//
//  RedditPostCell.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

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
    
    func with(post: ReditPostViewNode) -> RedditPostCell {
        if let thumbnail = post.post.thumbnail {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(onImageTap)
            )
            thumbnailImageView.addGestureRecognizer(gesture)
            thumbnailImageView.isUserInteractionEnabled = true
            thumbnailImageView.backgroundColor = .red
        } else {
            thumbnailImageView.backgroundColor = .gray
            thumbnailImageView.isUserInteractionEnabled = false
        }
        
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
    }
    
    @objc private func onImageTap(_ sender: UIView) {
         onActionTap?()
    }
}
