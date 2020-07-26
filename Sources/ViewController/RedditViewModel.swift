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
    
    private let api: RedditAPIType
    private let request: RedditRequest
    private let subject: CurrentValueSubject<State, Never> = CurrentValueSubject(.idle)
    
    var state: AnyPublisher<State, Never>
    
    init(
        api: RedditAPIType,
        request: RedditRequest
    ) {
        self.api = api
        self.request = request
        
        state = subject.eraseToAnyPublisher()
    }
}

// MARK: - Interactions
extension RedditViewModel {
    func activate() {
        update(to: .loading)
    }
    
    func reload() {
        //update(to: .loading)
        print("Reload")
    }
    
    func loadMore() {
        print("Load more")
    }
}

extension RedditViewModel {
    private func update(to newState: State) {
        let currentState = subject.value
        switch (currentState, newState) {
        case (.idle, .loading):
            print("start requesting")
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                self.subject.send(.loaded([PostViewModel(), PostViewModel()]))
            }
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
    
}
