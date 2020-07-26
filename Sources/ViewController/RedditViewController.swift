//
//  RedditViewController.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine

final class RedditViewController: UITableViewController {
    private let api: RedditAPIType = RedditAPI.default
    private let request: RedditRequest = RedditRequest(path: "top")
    
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.listing(for: request).sink(
            receiveCompletion: { completion in
                print(completion)
        }) { response in
//            print(response.data.children.map { $0.posts } )
            print(response.data )
        }.store(in: &subscriptions)
    }
}
