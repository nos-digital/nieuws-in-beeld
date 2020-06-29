//
//  NOSAPIClient.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 29/06/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import ScreenSaver


struct NOSAPIClient: APIClient
{
    enum NetworkError: Error
    {
        case unknown
    }
    
    static let photos = URL(string: "https://public-api.nos.nl/feed/nieuws-in-beeld.json")!
    
    func loadPhotos(completion: @escaping (Result<[Photo], Error>) -> Void)
    {
        let task = URLSession.shared.dataTask(with: NOSAPIClient.photos) { (data, response, error) in
            
            if let data = data {
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: data)
                    completion(.success(photos))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NetworkError.unknown))
            }
        }
        
        task.resume()
    }
    
    func loadImage(with url: URL, completion: @escaping (Result<NSImage, Error>) -> Void)
    {
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let location = location,
                let image = NSImage(contentsOf: location)
            {
                completion(.success(image))
            } else if let error = error
            {
                completion(.failure(error))
            } else {
                completion(.failure(NetworkError.unknown))
            }
        }
        
        task.resume()
    }
}
