//
//  NOSAPIClient.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 29/06/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import Foundation


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
                self.handleData(data, completion: completion)
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NetworkError.unknown))
            }
        }
        
        task.resume()
    }
    
    private func handleData(_ data: Data, completion: (Result<[Photo], Error>) -> Void)
    {
        do {
            let photos = try JSONDecoder().decode([Photo].self, from: data)
            completion(.success(photos))
        } catch {
            completion(.failure(error))
        }
    }
}
