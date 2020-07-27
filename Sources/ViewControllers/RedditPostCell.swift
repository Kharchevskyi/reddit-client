//
//  RedditPostCell.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class RedditPostCell: UITableViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var postTitleLabel: UILabel!
    @IBOutlet private var postCommentsLabel: UILabel!
    @IBOutlet private var postAuthorLabel: UILabel!
    
    func with(post: ReditPostViewNode) -> RedditPostCell {
        thumbnailImageView.backgroundColor = .red
        postTitleLabel.text = post.post.title
        postCommentsLabel.text = String(post.post.numberOfComments)
        postAuthorLabel.text = post.post.author
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.bounds.width / 2
    }
}
