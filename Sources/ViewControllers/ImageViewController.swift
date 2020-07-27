//
//  ImageViewController.swift
//  RedditClient
//
//  Created by Anton Kharchevskyi on 27/07/2020.
//  Copyright © 2020 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButton.layer.borderColor = UIColor.appBorderColor.cgColor
        actionButton.layer.borderWidth = 2
    }

    @IBAction func tapButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
