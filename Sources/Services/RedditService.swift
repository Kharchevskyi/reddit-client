//
//  RedditApiService.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Combine
import UIKit

protocol RedditServiceType {
    var posts: AnyPublisher<[RedditPost], Never> { get }
    var hasMore: Bool { get }
    
    func reload()
    func loadNext()
}

final class RedditService: RedditServiceType {
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
    var hasMore: Bool {
        guard case let .some(.pageLoaded(listing)) = self.pages.last else {
            return true
        }
        return listing.next != nil
    }
    
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
