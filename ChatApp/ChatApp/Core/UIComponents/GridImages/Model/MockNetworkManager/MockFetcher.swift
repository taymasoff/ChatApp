//
//  MockFetcher.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.11.2021.
//

import Foundation

class MockFetcher: GridImagesFetcherProtocol {
    let nm = MockNM()
    
    func fetchImagesList(query: String?, completion: @escaping ResultHandler<[GridPresentableImage]>) {
        nm.fetch(query: query) { result in
            switch result {
            case .success(let images):
                completion(.success(images))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMoreImages(completion: @escaping ResultHandler<[GridPresentableImage]>) {
        nm.fetch(query: nil) { result in
            switch result {
            case .success(let images):
                completion(.success(images))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPreviewImage(byURL url: String, completion: @escaping ResultHandler<UIImage>) {
        enum MockError: Error { case error1 }
        
        nm.fetch(string: url) { image in
            if let image = image {
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } else {
                completion(.failure(MockError.error1))
            }
        }
    }
    
    func fetchFullImage(byURL url: String, completion: @escaping ResultHandler<UIImage>) {
        enum MockError: Error { case error1 }
        
        nm.fetch(string: url) { image in
            if let image = image {
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } else {
                completion(.failure(MockError.error1))
            }
        }
    }
}
