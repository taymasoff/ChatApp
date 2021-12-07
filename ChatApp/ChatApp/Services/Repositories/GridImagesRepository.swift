//
//  ImageFetcher.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

final class GridImagesRepository: GridImagesRepositoryProtocol {

    private let requestDispatcher: RequestDispatcherProtocol
    private let imageFetcher: CachedImageFetcherProtocol
    private lazy var pixabayParser: PixabayModelsParser = PixabayModelsParser(jsonDecoder: JSONDecoder())
    
    init(requestDispatcher: RequestDispatcherProtocol = RequestDispatcher(),
         imageFetcher: CachedImageFetcherProtocol = CachedImageFetcher()) {
        self.requestDispatcher = requestDispatcher
        self.imageFetcher = imageFetcher
    }
    
    func fetchImagesList(query: String?,
                         completion: @escaping ResultHandler<[GridPresentableImage]>) {
        
        // При каждом обновлении списка чистим кэш
        imageFetcher.clearImageCache()
        
        var config: RequestConfig<PixabayModelsParser>
        
        if let query = query {
            config = RequestConfig(
                request: PixabayImageListsRequests.imagesByQuery(query),
                parser: pixabayParser
            )
        } else {
            config = RequestConfig(
                request: PixabayImageListsRequests.randomImages,
                parser: pixabayParser
            )
        }
        
        requestDispatcher.executeRequest(from: config) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let images):
                    completion(.success(images as [GridPresentableImage]))
                case .failure(let networkError):
                    completion(.failure(networkError))
                }
            }
        }
    }
    
    func fetchMoreImages(completion: @escaping ResultHandler<[GridPresentableImage]>) {
        fatalError("Fetch more images not yet supported")
    }
    
    func fetchPreviewImage(byURL url: String,
                           completion: @escaping ResultHandler<UIImage>) {
        imageFetcher.fetchCachedImage(from: url) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func fetchFullImage(byURL url: String,
                        completion: @escaping ResultHandler<UIImage>) {
        imageFetcher.fetchCachedImage(from: url) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
