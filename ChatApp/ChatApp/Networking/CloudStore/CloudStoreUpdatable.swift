//
//  CloudStoreUpdatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, представляющий поддержку ручного обновления модели из облачного хранилища
protocol CloudStoreUpdatable {
    
    /// Обновляет модель данных один раз
    /// - Parameter completion: сообщение об успехе или ошибка
    func updateModel(completion: @escaping ResultHandler<String>)
}
