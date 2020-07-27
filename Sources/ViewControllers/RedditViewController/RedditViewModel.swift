//
//  RedditViewModel.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import Combine

final class RedditViewModel: ObservableObject {
    // MARK: - Input
    enum Action {
        case idle
        case activate
        case reload
        case loadMore
    }
    @Published var action: Action = .idle
    
    // MARK: - Output
    enum State {
        case idle
        case loading
        case loaded([ReditPostViewNode], hasMore: Bool)
        
        var title: String {
            switch self {
            case .idle: return "Reddit"
            case .loading: return "Loading 🏋️‍♀️"
            case .loaded(let posts, _): return "Loaded \(posts.count)"
            }
        }
    }
    @Published private(set) var state: State = .idle
    
    // MARK: - Implemenetation
    private let redditService: RedditService
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        redditService = RedditService(api: api, request: request)
        
        redditService.posts
            .sink(receiveValue: { [weak self] value in
                self?.update(with: value)
            })
            .store(in: &subscriptions)
        
        $action
            .sink(receiveValue: { [weak self] action in
                self?.handle(action: action)
            })
            .store(in: &subscriptions)
    }

    private func update(with posts: [RedditPost]) {
        let newState: State = .loaded(
            posts.map(ReditPostViewNode.init),
            hasMore: redditService.hasMore
        )
        update(to: newState)
    }
}

// MARK: - Input handling
extension RedditViewModel {
    private func handle(action: Action) {
        switch action {
        case .activate:
            update(to: .loading)
            redditService.reload()
            
        case .reload:
            update(to: .loading)
            redditService.reload()
            
        case .loadMore:
            update(to: .loading)
            redditService.loadNext()
            
        case .idle: break
        }
    }
}

// MARK: - Output handling
extension RedditViewModel {
    private func update(to newState: State) {
        state = newState
    }
}
