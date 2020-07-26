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
    func listing(for request: RedditRequest) -> AnyPublisher<RedditResponse, Error>
}

final class RedditAPI: RedditAPIType {
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
    
    func listing(for request: RedditRequest) -> AnyPublisher<RedditResponse, Error> {
        guard let url = createURL(for: request) else {
            return Fail(error: APIError.wrongURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RedditResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
     
    private func createURL(for request: RedditRequest) -> URL? {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            return nil
        }
        
        components.path = "/" + request.path + ".json"
         
        return components.url
    }
}
