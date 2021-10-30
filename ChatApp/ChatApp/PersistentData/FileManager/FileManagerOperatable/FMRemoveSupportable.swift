//
//  FMRemoveSupportable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, представляющий поддержку работы файлового менеджера по удалению данных
protocol FMRemoveSupportable: FMOperatableBase, DataRemovable {
    func removeRecord(keyWithExtension: String, completion: @escaping CompletionHandler<Bool>)
}

// MARK: - FMModelOperatable Default Implementation
extension FMRemoveSupportable {
    func removeRecord(keyWithExtension: String,
                      completion: @escaping CompletionHandler<Bool>) {
        removeRecord(key: keyWithExtension, completion: completion)
    }
    
    func removeRecord(key: String, completion: @escaping CompletionHandler<Bool>) {
        do {
            try fileManager.deleteFile(key, at: fmPreferences.preferredDirectory)
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
}
