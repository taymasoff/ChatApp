//
//  DataParserProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import UIKit

/// Протокол, которому должен соответствовать парсер
protocol DataParserProtocol {
    associatedtype ModelType
    
    /// Распарсить модель в приемлемый вид
    /// - Returns: опциональная модель
    func parse(data: Data) -> ModelType?
}

// MARK: - Дефолтная реализация, где модель это Data
extension DataParserProtocol where ModelType == Data {
    func parse(data: Data) -> ModelType? {
        return data
    }
}

// MARK: - Дефолтная реализация, где модель это UIImage
extension DataParserProtocol where ModelType == UIImage {
    func parse(data: Data) -> ModelType? {
        return UIImage(data: data)
    }
}

// MARK: - Дефолтная реализация, где модель это Decodable объект
extension DataParserProtocol where ModelType: Decodable {
    func parse(data: Data) -> ModelType? {
        return try? JSONDecoder().decode(ModelType.self, from: data)
    }
}

// MARK: - Пачка дефолтных классов для удобства.
final class DefaultDataParser: DataParserProtocol {
    typealias ModelType = Data
}

final class DefaultImageParser: DataParserProtocol {
    typealias ModelType = UIImage
}
