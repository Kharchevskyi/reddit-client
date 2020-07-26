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
    // TODO: - Add DI. Fix initializtion
    private let api: RedditAPIType = RedditAPI.default
    private let request: RedditRequest = RedditRequest(path: "top")
    private lazy var viewModel = RedditViewModel(api: api, request: request)
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private let tableRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
        
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(loadMorePosts))
        tableView.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.activate()
    }
}

// MARK: - Setup
extension RedditViewController {
    private func setupUI() {
        tableView.separatorStyle = .none
        tableView.isOpaque = true
        
        tableRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = tableRefreshControl
    }
    
    private func setupViewModel() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.reload(with: value)
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Update
extension RedditViewController {
    private func reload(with state: RedditViewModel.State) {
        title = state.title
        
        switch state {
        case .idle:
            tableRefreshControl.endRefreshing()
        case .loaded:
            tableRefreshControl.endRefreshing()
        case .loading:
            tableRefreshControl.beginRefreshing()
        }
    }
}

extension RedditViewController {
    @objc private func refresh() {
        viewModel.reload()
    }
    
    @objc private func loadMorePosts() {
        viewModel.loadMore()
    }
}
