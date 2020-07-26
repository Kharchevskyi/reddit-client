//
//  RedditAPI.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 26/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import Combine

protocol RedditAPIType {
    func listing(for request: RedditRequest, limit: Int) -> AnyPublisher<RedditListingPage, Error>
}

struct RedditAPI: RedditAPIType {
    static var `default`: RedditAPI = RedditAPI(
        baseURL: URL(string: "https://reddit.com")!
    )
    
    enum APIError: Error {
        case wrongURL
    }
    
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    
    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
    }
    
    func listing(for request: RedditRequest, limit: Int = 25) -> AnyPublisher<RedditListingPage, Error> {
        createPublisher(
            for: request,
            baseURL: baseURL,
            session: session,
            limit: limit,
            decoder: decoder
        )
    }
    
    private func createPublisher(
        for request: RedditRequest,
        baseURL: URL,
        session: URLSession,
        limit: Int,
        after: String? = nil,
        decoder: JSONDecoder
    ) -> AnyPublisher<RedditListingPage, Error> {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            return Fail(error: RedditAPI.APIError.wrongURL).eraseToAnyPublisher()
        }
        
        components.path = "/" + request.path + ".json"
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
            + (after.map { [URLQueryItem(name: "after", value: "\($0)")] } ?? [])
        
        guard let url = components.url else {
            return Fail(error: RedditAPI.APIError.wrongURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RedditResponse.self, decoder: decoder)
            .map({ response in
                // get current listing
                let listing = response.data
                // create publisher for next page if possible
                let next = response.data
                    .after
                    .map {
                        self.createPublisher(
                            for: request,
                            baseURL: baseURL,
                            session: session,
                            limit: limit,
                            after: $0,
                            decoder: decoder
                        )
                    }
                
                return RedditListingPage(
                    listing: listing,
                    next: next
                )
            })
            .eraseToAnyPublisher()
    }
}
