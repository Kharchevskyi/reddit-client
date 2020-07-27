//
//  UIStoryboardExtensions.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

extension UIViewController {
    class var reuseIdentifier: String { "\(self)" }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        UIStoryboard(name: "Main", bundle: nil)
    }
    
    func instantiateViewController<T: UIViewController>(type: T.Type) -> T {
        self.instantiateViewController(identifier: type.reuseIdentifier)
    }
}

