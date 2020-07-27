//
//  TableViewExtensions.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class var reuseIdentifier: String { "\(self)" }
}

extension UITableView {
    func register<E: UITableViewCell>(_ type: E.Type) {
        let reuseIdentifier = type.reuseIdentifier
        
        if Bundle.main.path(forResource: reuseIdentifier, ofType: "nib") != nil {
            register(
                UINib(
                    nibName: reuseIdentifier,
                    bundle: nil
                ),
                forCellReuseIdentifier: reuseIdentifier
            )
        }
        else {
            register(type, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<E: UITableViewCell>(
        with type: E.Type,
        for indexPath: IndexPath
    ) -> E {
        dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as! E
    }
}
