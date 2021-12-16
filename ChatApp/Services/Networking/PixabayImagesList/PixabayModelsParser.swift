//
//  PixabayModelsParser.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

class PixabayModelsParser: DataParserProtocol {
    
    private let jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    func parse(data: Data) -> [PixabayImage]? {
        return try? jsonDecoder.decode(PixabayResponse.self, from: data).hits
    }
}
