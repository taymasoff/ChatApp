//
//  CachedImageFetcher.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/// Тот же самый URLImageFetchable, только с кешированием изображений
protocol CachedImageFetcherProtocol: URLImageFetchable {
    func clearImageCache()
    func fetchCachedImage(from url: URL,
                          completion: @escaping ResultHandler<UIImage>)
    func fetchCachedImage(from url: String,
                          completion: @escaping ResultHandler<UIImage>)
}

final class CachedImageFetcher: CachedImageFetcherProtocol {
    
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache = ImageCache()) {
        self.imageCache = imageCache
    }
    
    func clearImageCache() {
        imageCache.clearCache()
    }
    
    func fetchCachedImage(from url: URL,
                          completion: @escaping ResultHandler<UIImage>) {
        guard let image = imageCache[url.absoluteString] else {
            (self as URLImageFetchable).fetchImage(from: url) { [weak self] result in
                if case .success(let image) = result {
                    self?.imageCache[url.absoluteString] = image
                }
                completion(result)
            }
            return
        }
        completion(.success(image))
    }
    
    func fetchCachedImage(from url: String,
                          completion: @escaping ResultHandler<UIImage>) {
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.badInput("\(url) не является валидным URL")))
            return
        }
        fetchCachedImage(from: url, completion: completion)
    }
}
