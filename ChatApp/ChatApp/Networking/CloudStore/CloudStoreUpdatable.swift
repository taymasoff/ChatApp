//
//  CloudStoreUpdatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, представляющий поддержку ручного обновления модели из облачного хранилища
protocol CloudStoreUpdatable {
    associatedtype ModelType: Codable
    
    /// Обновляет модель данных один раз
    /// - Parameter completion: сообщение об успехе или ошибка
    func updateModel(enableLogging: Bool,
                     completion: @escaping ResultHandler<CSModelUpdateLog<ModelType>?>)
}
