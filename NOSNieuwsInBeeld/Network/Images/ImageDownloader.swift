//
//  ImageDownloader.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


struct ImageDownloader: ImageLoading
{
    var cache = ImageCache()
    
    enum ImageError: Error
    {
        case unknown
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<NSImage, Error>) -> Void)
    {
        if let image = cache.cachedImage(for: url) {
            completion(.success(image))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let location = location, let image = NSImage(contentsOf: location) {
                self.cache.cacheImage(image, with: url)
                completion(.success(image))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(ImageError.unknown))
            }
        }
        
        task.resume()
    }
}
