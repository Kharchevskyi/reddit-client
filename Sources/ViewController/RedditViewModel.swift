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
        case loaded
        
        var title: String {
            switch self {
            case .idle: return "Reddit"
            case .loading: return "Loading"
            case .loaded: return "Loaded"
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
    
    func activate() {
        // test
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.subject.send(.loaded)
        }
    }
}

