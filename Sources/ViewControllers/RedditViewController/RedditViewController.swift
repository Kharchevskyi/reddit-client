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
    private var viewModel: RedditViewModel!
    
    private var subscriptions: Set<AnyCancellable> = []
   
    private let tableRefreshControl = UIRefreshControl()
    @IBInspectable var path: String = "top"
    private var posts: [ReditPostViewNode] = []
    private var hasMore = true
    
    // MARK: - Initialisation
     
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        super.init(style: .grouped)
        self.api = api
        self.request = request
        createViewModel()
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
        createViewModel()
    }
    
    private func createViewModel() {
        viewModel = RedditViewModel(api: api, request: request)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.action = .activate
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(with: RedditPostCell.self, for: indexPath)
            .with(post: posts[indexPath.row])
            .onAction { [weak self] url in
                self?.handleImageTapAction(with: url)
            }
    }
}

// MARK: - Setup
extension RedditViewController {
    private func setupUI() {
        tableView.backgroundColor = .appBackgroundColor
        tableView.separatorStyle = .none
        tableView.isOpaque = true
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        tableRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = tableRefreshControl
    }
    
    private func setupViewModel() {
        viewModel.$state
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
        switch state {
        case .idle:
            tableRefreshControl.endRefreshing()
        
        case .loading:
            tableRefreshControl.beginRefreshing()
            
        case let .loaded(loadedPosts, hasNext):
            tableRefreshControl.endRefreshing()
            posts = loadedPosts
            hasMore = hasNext
        }
        
        title = state.title
        tableView.reloadData()
    }
}

// MARK: - Action handling
extension RedditViewController {
    @objc private func refresh() {
        viewModel.action = .reload
    }
    
    @objc private func loadMorePosts() {
        viewModel.action = .loadMore
    }
    
    func handleImageTapAction(with url: URL?) {
        guard let url = url else { return }
        present(UIStoryboard.main.instantiateViewController(type: ImageViewController.self), animated: true, completion: nil)
    }
}
