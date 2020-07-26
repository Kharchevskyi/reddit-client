//
//  RedditResponse.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Foundation

struct RedditResponse: Codable {
    let data: RedditListing
}

struct RedditListing: Codable {
    let after: String?
    let children: [RedditChild]
}

struct RedditChild: Codable {
    let posts: RedditPost
    
    enum CodingKeys: String, CodingKey {
        case posts = "data"
    }
}
