//
//  CloudStoreRemovable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, представляющий поддержку удаления сущности из облачного храналища
protocol CloudStoreRemovable {
    
    /// Удалить сущность по ее уникальному ключу
    /// - Parameters:
    ///   - id: уникальный ID сущности
    ///   - completion: Result с сообщением успеха или ошибки
    func deleteEntity(withID id: String, completion: @escaping ResultHandler<String>)
}
