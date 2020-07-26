//
//  RedditPost.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Foundation

struct RedditPost: Codable {
    let title: String
    let author: String
    let thumbnail: URL?
    let numberOfComments: Int
    
    enum CodingKeys : String, CodingKey {
        case title
        case author
        case thumbnail = "thumbnail"
        case numberOfComments = "num_comments"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.numberOfComments = try container.decode(Int.self, forKey: .numberOfComments)
        self.thumbnail = (try? container.decode(String.self, forKey: .thumbnail))
            .flatMap { ($0.hasPrefix("http") || $0.hasPrefix("https")) ? $0 : nil }
            .flatMap(URL.init)
    }
}
