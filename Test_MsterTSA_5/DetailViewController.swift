//
//  DetailViewController.swift
//  Test_MsterTSA_5
//
//  Created by Marro Gros Gabriel on 30/11/2018.
//  Copyright © 2018 Marro Gros Gabriel. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var flag: AsyncImageView!

    var detailItem: Country?
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            name.text = detail.name
            flag.image = nil
            if let countryCode = detail.code {
                let urlString = "http://apptones.net/test02_assets/\(countryCode.lowercased()).png"
                
                if let url = URL(string: urlString) {
                    flag.fillWithURL(url, place: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    var firstTime = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard firstTime else {
            return
        }
        
        flag.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard firstTime else {
            return
        }
        
        firstTime = false
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.flag.transform = .identity
        }
        
    }

    


}

