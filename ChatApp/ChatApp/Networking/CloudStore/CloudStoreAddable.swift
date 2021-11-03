//
//  CloudStoreAddable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, представляющий поддержку добавления сущности в облачное хранилище из модели
protocol CloudStoreAddable {
    associatedtype ModelType
    
    /// Добавить сущность, созданную из модели
    /// - Parameters:
    ///   - model: encodable модель
    ///   - completion: Result с сообщением успеха или ошибки
    func addEntity(from model: ModelType, completion: ResultHandler<String>)
}
