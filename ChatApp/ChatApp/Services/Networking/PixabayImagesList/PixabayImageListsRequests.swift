//
//  ImageFetcherRequests.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

enum PixabayImageListsRequests: RequestProtocol {
    
    case randomImages
    case imagesByQuery(String)
    
    var baseURL: String {
        return "pixabay.com"
    }
    
    var path: String {
        return "/api"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: RequestParameters? {
        switch self {
        case .randomImages:
            return .url([
                "key": AppData.pixabayAPIKey,
                "safesearch": "true",
                "per_page": "\(Int.random(in: 150..<200))"
            ])
        case .imagesByQuery(let query):
            return .url([
                "key": AppData.pixabayAPIKey,
                "safesearch": "true",
                "per_page": "\(Int.random(in: 150..<200))",
                "q": query
            ])
        }
    }
    
    var timeoutInteval: TimeInterval? {
        return 15
    }
}
