//
//  RedditListingPage.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Combine

struct RedditListingPage {
    let listing: RedditListing
    let next: AnyPublisher<RedditListingPage, Error>?
}
