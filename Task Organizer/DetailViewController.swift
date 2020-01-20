//
//  DetailViewController.swift
//  Task Organizer
//
//  Created by otet_tud on 1/19/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

//    func configureView() {
//        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail["url"].stringValue
//                if let url = URL(string: detail["url"].stringValue) {
//                    let request = URLRequest(url: url)
//                    webView.load(request)
//                }
//            }
//        }
//    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.getTitle()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Task? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

