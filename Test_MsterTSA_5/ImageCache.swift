//
//  ImageCache.swift
//  TestMasterTsa_3
//
//  Created by Marro Gros Gabriel on 23/11/2018.
//  Copyright © 2018 Marro Gros Gabriel. All rights reserved.
//

import UIKit

class ImageCache {
    
    let memCache = NSCache<NSString, UIImage>()
    
    static let shared = ImageCache()
    
    func imageWithURL(_ url: URL, completion: @escaping (UIImage?)->Void ) {
        
        if let image = memCache.object(forKey: url.absoluteString as NSString) {
            completion(image)
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let fm = FileManager.default
            if let docs = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let file = docs.appendingPathComponent( url.lastPathComponent )
                if let image = UIImage(contentsOfFile: file.path) {
                    
                    completion(image)
                    self?.memCache.setObject(image, forKey: url.absoluteString as NSString)
                    
                    return
                }
            }
            
            self?.downloadImage(url, completion: completion)
        }
    }
    
    private func downloadImage(_ url: URL, completion: @escaping (UIImage?)->Void ) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            
            guard error == nil && data != nil else {
                completion(nil)
                return
            }
            
            if let image = UIImage(data: data!) {
                completion(image)
                
                self?.memCache.setObject(image, forKey: url.absoluteString as NSString)
                
                let fm = FileManager.default
                if let docs = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                    let file = docs.appendingPathComponent(url.lastPathComponent)
                    
                    if let data = image.pngData() {
                        try? data.write(to: file)
                    }
                    
                }
            } else {
                completion(nil)
            }
            
        }
        
        task.resume()
    }
}
