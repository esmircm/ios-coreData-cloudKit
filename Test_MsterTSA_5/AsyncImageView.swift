//
//  AsyncImageView.swift
//  TestMasterTsa_3
//
//  Created by Marro Gros Gabriel on 23/11/2018.
//  Copyright © 2018 Marro Gros Gabriel. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView {
    
    var lastMark: UUID? = nil
    
    func fillWithURL(_ url: URL, place: String?) {
        
        self.image = place != nil ? UIImage(named: place!) : nil
        
        let mark = UUID()
        
        self.lastMark = mark
        
        ImageCache.shared.imageWithURL(url) {[weak self] (image) in
            
            guard self?.lastMark == mark else {
                return
            }
            
            guard image != nil else {
                return
            }
            
            if Thread.isMainThread {
                self?.image = image!
            } else {
                DispatchQueue.main.async {
                    self?.image = image!
                }
            }
        }
    }
}
