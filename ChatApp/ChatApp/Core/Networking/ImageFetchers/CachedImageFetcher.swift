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
}

final class CachedImageFetcher: CachedImageFetcherProtocol {
    
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache = ImageCache()) {
        self.imageCache = imageCache
    }
    
    func clearImageCache() {
        imageCache.clearCache()
    }
    
    func fetchImage(from url: URL,
                    in urlSession: URLSession? = nil,
                    completion: @escaping ResultHandler<UIImage>) {
        guard let image = imageCache[url.absoluteString] else {
            (self as URLImageFetchable).fetchImage(from: url,
                                                   in: urlSession,
                                                   completion: completion)
            return
        }
        completion(.success(image))
    }
    
    func fetchImage(from url: String,
                    in urlSession: URLSession? = nil,
                    completion: @escaping ResultHandler<UIImage>) {
        guard let image = imageCache[url] else {
            (self as URLImageFetchable).fetchImage(from: url,
                                                   in: urlSession,
                                                   completion: completion)
            return
        }
        completion(.success(image))
    }
}
