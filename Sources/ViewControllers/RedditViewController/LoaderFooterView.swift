//
//  LoaderFooterView.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 29/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class LoaderFooterView: UITableViewHeaderFooterView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        activityIndicator.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.center = contentView.center
    }
}

final class EmptyFooterView: UITableViewHeaderFooterView {
    
}
