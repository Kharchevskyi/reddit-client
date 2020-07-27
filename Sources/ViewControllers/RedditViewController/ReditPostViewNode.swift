//
//  ReditPostViewNode.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

struct ReditPostViewNode {
    let title: NSAttributedString
    let commentsCount: NSAttributedString
    let author: NSAttributedString
    let thumbnailURL: URL?
    
    init(_ post: RedditPost) {
        let color = UIColor.appTextColor as Any
        self.title = NSAttributedString(
            string: post.title,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                NSAttributedString.Key.foregroundColor: color
            ]
        )
        
        self.commentsCount = NSAttributedString(
            string: "💻 " + String(post.numberOfComments),
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                NSAttributedString.Key.foregroundColor: color
            ]
        )
        
        self.author = NSAttributedString(
            string: post.author + " ©",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                NSAttributedString.Key.foregroundColor: color
            ]
        )
        
        self.thumbnailURL = post.thumbnail
    }
}
