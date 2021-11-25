//
//  ImageFetcher.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/*
 Мне показалось, что в случае простой закачки картинки нет смысла использовать Request, парсер и диспетчер поэтому сделал так
 */

/// Простой ImageFetcher, который принимает URL и возвращает результат с изображением или ошибкой
protocol URLImageFetchable: ResponseHandling {
    func fetchImage(from url: String,
                    in urlSession: URLSession?,
                    completion: @escaping ResultHandler<UIImage>)
    func fetchImage(from url: URL,
                    in urlSession: URLSession?,
                    completion: @escaping ResultHandler<UIImage>)
}

// MARK: - URLImageFetchable Default Implementation
extension URLImageFetchable {
    
    func fetchImage(from url: URL,
                    in urlSession: URLSession? = nil,
                    completion: @escaping ResultHandler<UIImage>) {
        
        let urlSession: URLSession = urlSession ?? URLSession.shared
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        
        urlSession.dataTask(with: url) { data, urlResponse, error in
            let result = handleURLResponse(data, urlResponse, error)
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(
                        .failure(NetworkError.parsingError("Не удалось преобразовать данные в изображение"))
                    )
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchImage(from url: String,
                    in urlSession: URLSession? = nil,
                    completion: @escaping ResultHandler<UIImage>) {
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.badInput("Передан неверный URL")))
            return
        }
        
        fetchImage(from: url, completion: completion)
    }
}
