//
//  FSAddable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation
import FirebaseFirestore

/// Тип, представляющий поддержку работы Firestore с методом добавления нового документа из модели
protocol FSAddable: FSOperatableBase {
    
    /// Добавить документ, созданный из модели
    /// - Parameters:
    ///   - model: encodable модель
    ///   - completion: Result с сообщением успеха или ошибки
    func addDocument(from model: ModelType, completion: ResultHandler<String>)
}

// MARK: - FSAddable Default Implementation
extension FSAddable where ModelType: Encodable {

    // MARK: Add Document
    func addDocument(from model: ModelType, completion: ResultHandler<String>) {
        do {
            _ = try reference.addDocument(from: model)
            completion(
                .success("Документ успешно добавлен")
            )
        } catch {
            completion(
                .failure(FirestoreError.documentAddError)
            )
        }
    }
}
