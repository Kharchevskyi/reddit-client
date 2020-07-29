//
//  CollectionExtensions.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 29/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import Foundation

protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

extension Occupiable {
    var isNotEmpty: Bool { !isEmpty }
}

extension String: Occupiable { }
extension Array: Occupiable { }
extension Dictionary: Occupiable { }
extension Set: Occupiable { }

