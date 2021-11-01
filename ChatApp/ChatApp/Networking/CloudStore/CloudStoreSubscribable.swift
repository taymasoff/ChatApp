//
//  CloudStoreSubscribable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

typealias FSUpdatesListener = (_ updateLog: String?, _ error: Error?) -> Void

/// Тип, представляющий поддержку методов подписки и отписки облачного хранилища
protocol CloudStoreSubscribable {
    
    /// Подписывается на обновления и обновляет model при любом изменении
    /// - Parameters:
    /// - listener: замыкание, принимающее опциональный список изменений updateLog или ошибку error
    /// - updateLog: оцпиональная строка, содержащая в себе список изменений
    /// - error: опциональный Error
    func subscribeToUpdates(listener: @escaping FSUpdatesListener)
    
    /// Отписывается от обновлений
    func unsubscribeFromUpdates()
}
