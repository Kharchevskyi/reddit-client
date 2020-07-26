//
//  RedditViewModel.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import Combine

final class RedditViewModel {
    enum State {
        case idle
        case loading
        case loaded([PostViewModel])
        
        var title: String {
            switch self {
            case .idle: return "Reddit"
            case .loading: return "Loading 🏋️‍♀️"
            case .loaded(let posts): return "Loaded \(posts.count)"
            }
        }
    }
     
    private let subject: CurrentValueSubject<State, Never> = CurrentValueSubject(.idle)
    private let redditService: RedditApiService
    private var subscriptions: Set<AnyCancellable> = []
    
    var state: AnyPublisher<State, Never>
    
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        self.redditService = RedditApiService(
            api: api,
            request: request
        )
        redditService.posts.map {
            $0.map { PostViewModel(post: $0) }
        }
        .sink(receiveValue: { value in
            print(value.count)
        })
            .store(in: &subscriptions)
        
        
        state = subject.eraseToAnyPublisher()
    }
}

// MARK: - Interactions
extension RedditViewModel {
    func activate() {
        update(to: .loading)
        redditService.reload()
    }
    
    func reload() {
        //update(to: .loading)
        print("Reload")
        
    }
    
    func loadMore() {
        print("Load more")
        redditService.loadNext()
    }
}

extension RedditViewModel {
    private func update(to newState: State) {
        let currentState = subject.value
        switch (currentState, newState) {
        case (.idle, .loading):
            print("start requesting")
        case (.loading, .loading):
            print("Loading. Do nothing")
        default:
            print(currentState)
        }
        
        subject.send(newState)
    }
}

// MARK: - TODO:
struct PostViewModel {
    let post: RedditPost
}

// MARK: - RedditApiService:
protocol RedditApiServiceType {
    var posts: AnyPublisher<[RedditPost], Never> { get }
    func reload()
    func loadNext()
}

final class RedditApiService {
    private enum State {
        case pageLoaded(RedditListingPage)
        case pageLoading(AnyCancellable)
        
        var posts: [RedditPost] {
            guard case let .pageLoaded(posts) = self else { return [] }
            return posts.listing.children.map { $0.posts }
        }
    }
    
    private let api: RedditAPIType
    private let request: RedditRequest
    private let queue = DispatchQueue(label: "com.kharchevskyi.RedditClient.RedditApiService.queue")
    private var subscriptions: Set<AnyCancellable> = []
    
    private var postsSubject: CurrentValueSubject<[RedditPost], Never> = CurrentValueSubject([])
    private var pages: [State] = []
    
    var posts: AnyPublisher<[RedditPost], Never> { postsSubject.eraseToAnyPublisher() }
    
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        self.api = api
        self.request = request
    }
    
    func reload() {
        queue.async {
            self.pages = []
            self.add(listing: self.api.listing(for: self.request, limit: 25))
        }
    }
    
    func loadNext() {
        queue.async {
            // get last loaded page
            guard let last = self.pages.last, case let .pageLoaded(listing) = last else {
                return
            }
            
            // load next page if possible
            guard let next = listing.next else {
                return
            }
            
            self.add(listing: next)
        }
    }
    
    private func add(listing: AnyPublisher<RedditListingPage, Error>) {
        let index = pages.count
        let subscription = listing.subscribe(on: queue)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] page in
                    guard let self = self else { return }
                    self.updatePage(with: index, listing: page)
                })
        pages.append(.pageLoading(subscription))
    }
    
    private func updatePage(with index: Int, listing: RedditListingPage) {
        pages[index] = .pageLoaded(listing)
        postsSubject.send(self.pages.flatMap { $0.posts })
    }
}
