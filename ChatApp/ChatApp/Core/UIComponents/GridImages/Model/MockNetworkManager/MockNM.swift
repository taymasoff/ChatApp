//
//  MockNM.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 21.11.2021.
//

import UIKit

struct Response: Decodable {
    let hits: [Image]
}

struct Image: Decodable {
    let previewURL: String
    let webformatURL: String
    let previewWidth: Int
    let previewHeight: Int
}

extension Image: GridPresentableImage {
    var previewImageURL: String {
        return previewURL
    }
    
    var fullImageURL: String {
        return webformatURL
    }
    
    var imageHeight: CGFloat {
        return CGFloat(previewHeight)
    }
    
    var imageWidth: CGFloat {
        return CGFloat(previewWidth)
    }
}

class MockNM {
    var counter = 0
    
    let cache = NSCache<NSString, UIImage>()
    
    func fetch(query: String?, completion: @escaping ResultHandler<[Image]>) {
        URLSession.shared.dataTask(with: URL(
            string:
                "https://pixabay.com/api/?key=24447993-d83826e9b7088e14b4ae65ef0&q=\(query ?? "")&per_page=200&image_type=photo"
        )!) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let response = try? JSONDecoder().decode(Response.self, from: data!)
                completion(.success(response!.hits))
            }
        }.resume()
    }
    
    func fetch(string: String, completion: @escaping (UIImage?) -> Void) {        
        if let image = cache.object(forKey: string as NSString) {
            completion(image)
        }
        
        URLSession.shared.dataTask(with: URL(string: string)!) { data, _, error in
            if error != nil {
                completion(nil)
            } else {
                let image = UIImage(data: data!)!
                self.cache.setObject(image, forKey: string as NSString)
                completion(image)
            }
        }.resume()
    }
}
