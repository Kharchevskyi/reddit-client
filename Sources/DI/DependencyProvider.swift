//
//  DependencyProvider.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

struct DependencyProvider {
    private let dependencies: [String: Any]
    
    init(dependencies: [String: Any] = [:]) {
        self.dependencies = dependencies
    }
    
    func register<T>(type: T.Type, instance: T) -> DependencyProvider {
        var deps = dependencies
        deps["\(type.self)"] = instance
        return DependencyProvider(dependencies: deps)
    }
    
    func resolve<T>(type: T.Type) -> T? {
        dependencies["\(type)"].flatMap { $0 as? T }
    }
}

 
func inject<T>(
    type: T.Type,
    responder: UIResponder,
    fallback: @autoclosure () -> (T)
) -> T {
    let appTarget = UIApplication.shared.target(
        forAction: Selector(("dependencyProvider")),
        withSender: nil
    )

    let responderRarget = responder.target(
        forAction: Selector(("dependencyProvider")),
        withSender: nil
    )
     

    let target = responderRarget ?? appTarget
    let provider = target.flatMap { $0 as? DependencyProvider }
    let dependency = provider.flatMap { $0.resolve(type: type) }

    return dependency ?? fallback()
}
