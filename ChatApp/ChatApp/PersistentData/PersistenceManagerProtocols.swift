//
//  PersistenceManagerProtocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import Foundation

/*
 👉 В этом файле описаны протоколы и расширения для работы PersistenceManager'а
 */

// MARK: - PersistenceManagerProtocol
typealias PersistenceManagerProtocol = PMBase & PMSaveable & PMFetchable & PMRemovable

// MARK: - Persistence Manager Error
enum PMError: Error {
    case nilValue
}

// MARK: - Persistence Manager Base
protocol PMBase {
    var storageType: StorageType { get set }
}

// MARK: - Persistence Manager Saveable
protocol PMSaveable: PMBase {
    func save(_ string: String, key: String,
              completion: @escaping CompletionHandler<Bool>)
    func save(_ image: UIImage, key: String,
              completion: @escaping CompletionHandler<Bool>)
    func save<T: Encodable>(_ model: T, key: String,
                            completion: @escaping CompletionHandler<Bool>)
}

// MARK: - Persistence Manager Loadable
protocol PMFetchable: PMBase {
    func fetchString(key: String, completion: @escaping CompletionHandler<String>)
    func fetchImage(key: String, completion: @escaping CompletionHandler<UIImage>)
    func fetchModel<T: Decodable>(key: String, completion: @escaping CompletionHandler<T>)
}

protocol PMRemovable: PMBase {
    func removeRecord(key: String, completion: @escaping CompletionHandler<Bool>)
}

// MARK: - Decoding Error
enum CodingError: Error {
    case imageDecodingError
    case imageEncodingError
    case jsonDecodingError
    case jsonEncodingError
}

// MARK: - FromDataConvertable
protocol FromDataConvertable {
    func convertToString(_ data: Data) -> String
    func convertToImage(_ data: Data) throws -> UIImage
    func convertToModel<T: Decodable>(_ data: Data) throws -> T
}

extension FromDataConvertable {
    func convertToString(_ data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
    
    func convertToImage(_ data: Data) throws -> UIImage {
        if let image = UIImage(data: data) {
            return image
        } else {
            throw CodingError.imageDecodingError
        }
    }
    
    func convertToModel<T: Decodable>(_ data: Data) throws -> T  {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CodingError.jsonDecodingError
        }
    }
}

// MARK: - ToDataConvertable
protocol ToDataConvertable {
    func convertToData(_ string: String) -> Data
    func convertToData(_ image: UIImage) throws -> Data
    func convertToData<T: Encodable>(_ model: T) throws -> Data
}

extension ToDataConvertable {
    func convertToData(_ string: String) -> Data {
        return Data(string.utf8)
    }
    
    func convertToData<T: Encodable>(_ model: T) throws -> Data {
        do {
            return try JSONEncoder().encode(model)
        } catch {
            throw CodingError.jsonEncodingError
        }
    }
}

extension ToDataConvertable where Self: PMBase {
    func convertToData(_ image: UIImage) throws -> Data {
        switch storageType {
        case .fileManger(_, let pref):
            switch pref.preferredImageExtension {
            case .png:
                if let data = image.pngData() {
                    return data
                } else {
                    throw CodingError.imageEncodingError
                }
            case .jpeg:
                if let data = image.jpegData(compressionQuality: 1.0) {
                    return data
                } else {
                    throw CodingError.imageEncodingError
                }
            }
        case .userDefaults(_):
            if let data = image.pngData() {
                return data
            } else {
                throw CodingError.imageEncodingError
            }
        }
    }
}
