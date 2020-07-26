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
    private var api: RedditAPIType!
    private var request: RedditRequest!
    private lazy var viewModel = RedditViewModel(api: api, request: request)
    
    private var subscriptions: Set<AnyCancellable> = []
    private let tableRefreshControl = UIRefreshControl()
    @IBInspectable var path: String = "top"
    
    // MARK: - Initialisation
     
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        super.init(style: .grouped)
        self.api = api
        self.request = request
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.api = inject(
            type: RedditAPIType.self,
            responder: self,
            fallback: RedditAPI.default
        )
        self.request = RedditRequest(path: path)
    }
    
    // MARK: - LifeCycle
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

// MARK: - State handling
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

// MARK: - Updates
extension RedditViewController {
    @objc private func refresh() {
        viewModel.reload()
    }
    
    @objc private func loadMorePosts() {
        viewModel.loadMore()
    }
}
