//
//  ToDataConvertable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, предоставляющий базовые возможности конвертации строки/картинки или generic модели в Data
protocol ToDataConvertable {
    func convertToData(_ string: String?) -> Data
    func convertToData(_ image: UIImage?, as imageExtension: ImageExtension) throws -> Data
    func convertToData<T: Encodable>(_ model: T?) throws -> Data
}

// MARK: Default Implementation
extension ToDataConvertable {
    func convertToData(_ string: String?) -> Data {
        return Data(string?.utf8 ?? "".utf8)
    }
    
    func convertToData<T: Encodable>(_ model: T?) throws -> Data {
        do {
            return try JSONEncoder().encode(model)
        } catch {
            throw CodingError.jsonEncodingError
        }
    }
    
    func convertToData(_ image: UIImage?,
                       as imageExtension: ImageExtension) throws -> Data {
        guard let image = image else {
            throw CodingError.nilValue
        }

        switch imageExtension {
        case .png:
            if let data = image.pngData() {
                return data
            } else {
                throw CodingError.imageEncodingError
            }
        case .jpeg(let cQuality):
            if let data = image.jpegData(compressionQuality: cQuality) {
                return data
            } else {
                throw CodingError.imageEncodingError
            }
        }
    }
}
