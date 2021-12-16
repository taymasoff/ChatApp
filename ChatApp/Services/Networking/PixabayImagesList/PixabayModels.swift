//
//  PixabayModels.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

struct PixabayResponse: Decodable {
    let hits: [PixabayImage]
}

struct PixabayImage: Decodable {
    let previewURL: String
    let webformatURL: String
    let previewWidth: Int
    let previewHeight: Int
}

extension PixabayImage: GridPresentableImage {
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
