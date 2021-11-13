//
//  FromDataConvertable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, предоставляющий базовые возможности конвертации данных в объекты строки/картинки или generic модели
protocol FromDataConvertable {
    func convertToString(_ data: Data?) -> String
    func convertToImage(_ data: Data?) throws -> UIImage
    func convertToModel<T: Decodable>(_ data: Data?) throws -> T
}

// MARK: Default Implementation
extension FromDataConvertable {
    func convertToString(_ data: Data?) -> String {
        if let data = data {
            return String(decoding: data, as: UTF8.self)
        } else {
            return ""
        }
    }
    
    func convertToImage(_ data: Data?) throws -> UIImage {
        guard let data = data else { throw CodingError.nilValue }
        if let image = UIImage(data: data) {
            return image
        } else {
            throw CodingError.imageDecodingError
        }
    }
    
    func convertToModel<T: Decodable>(_ data: Data?) throws -> T {
        guard let data = data else { throw CodingError.nilValue }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CodingError.jsonDecodingError
        }
    }
}
