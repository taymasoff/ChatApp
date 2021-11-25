//
//  ImageRetrieverProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.11.2021.
//

import Foundation

protocol ImageRetrieverProtocol {
            
    /// Достает первое изображение из текста, а так же форматирует текст, чтобы убрать из него ссылку или добавить сообщение о неподдерживаемом API
    func retrieveFirstImage(
        fromText text: String,
        completion: @escaping (_ image: UIImage?, _ newText: String?) -> Void
    )
}

class ImageRetriever: ImageRetrieverProtocol, ImageLinksDetecting {
    
    enum OnFailConfiguration {
        case failImage(imageToDisplay: UIImage)
        case failText(textToAppend: String)
        case failTextWithError(textToAppend: String)
    }
    
    private let imageFetcher: CachedImageFetcherProtocol
    private let onFailConfiguration: OnFailConfiguration
    
    init(imageFetcher: CachedImageFetcherProtocol,
         onFailConfiguration: OnFailConfiguration =
            .failTextWithError(textToAppend: "Link API is not supported")) {
        self.imageFetcher = imageFetcher
        self.onFailConfiguration = onFailConfiguration
    }
    
    func retrieveFirstImage(
        fromText text: String,
        completion: @escaping (_ image: UIImage?, _ newText: String?) -> Void
    ) {
        
        findFirstImageLink(
            inText: text
        ) { [weak self] (output: (link: URL, newText: String)?) in
            guard let output = output,
                  let self = self else { completion(nil, nil); return }
            self.imageFetcher.fetchCachedImage(from: output.link) { result in
                switch result {
                case .success(let image):
                    completion(image, output.newText)
                case .failure(let error):
                    let formattedOutput = self.formatOutputOnError(
                        error: error,
                        inputText: text,
                        outputText: output.newText
                    )
                    completion(formattedOutput.0, formattedOutput.1)
                }
            }
        }
    }
    
    private func formatOutputOnError(
        error: Error,
        inputText: String,
        outputText: String
    ) -> (UIImage?, String?) {
        switch onFailConfiguration {
        case .failImage(let imageToDisplay):
            return (imageToDisplay, nil)
        case .failText(let textToAppend):
            return (
                nil,
                [inputText, "(\(textToAppend))"].joined(separator: " ")
            )
        case .failTextWithError(let textToAppend):
            let networkError: NetworkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
            return (
                nil,
                [inputText, "(\(textToAppend): \(networkError.localizedDescription))"]
                    .joined(separator: " ")
            )
        }
    }
}
