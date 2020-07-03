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
    enum ImageError: Error
    {
        case unknown
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<NSImage, Error>) -> Void)
    {
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let location = location, let image = NSImage(contentsOf: location) {
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
