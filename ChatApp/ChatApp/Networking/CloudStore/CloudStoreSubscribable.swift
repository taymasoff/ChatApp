//
//  CloudStoreSubscribable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, представляющий поддержку методов подписки и отписки облачного хранилища
protocol CloudStoreSubscribable: DynamicModelBasedCloudStore {
    
    /// Подписывается на обновления и обновляет model при любом изменении
    /// - Parameters:
    /// - enableLogging: при включенной опции listener будет возвращать тип CSModelUpdateLog, в котором содержатся массивы объектов, разбитых на группы added/updated/removed
    /// - listener: замыкание, принимающее опциональный список изменений CSModelUpdateLog или ошибку error
    func subscribeToUpdates(enableLogging: Bool,
                            listener: @escaping ResultHandler<CSModelUpdateLog<ModelType>?>)
    
    /// Отписывается от обновлений
    func unsubscribeFromUpdates()
}
