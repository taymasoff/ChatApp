//
//  FSRemovable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation
import FirebaseFirestore

/// Тип, представляющий поддержку работы Firestore с методом удаления документа
protocol FSRemovable: FSOperatableBase {
    
    /// Удалить документ по его ID
    /// - Parameters:
    ///   - key: ID документа
    ///   - completion: Result с сообщением успеха или ошибки
    func deleteDocument(withID id: String, completion: @escaping ResultHandler<String>)
}

// MARK: - FSRemovable Default Implementation
extension FSRemovable {
    
    // MARK: Delete Document
    func deleteDocument(withID id: String,
                        completion: @escaping ResultHandler<String>) {
        reference.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Документ успешно удален"))
            }
        }
    }
}
