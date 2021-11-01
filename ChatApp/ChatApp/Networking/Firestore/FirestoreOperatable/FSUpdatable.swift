//
//  FSUpdatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation
import FirebaseFirestore

/// Тип, представляющий поддержку работы Firestore с методом обновления модели
protocol FSUpdatable: FSOperatableBase {
    
    /// Обновляет модель данных один раз
    /// - Parameter completion: сообщение об успехе или ошибка
    func updateModel(completion: @escaping ResultHandler<String>)
}

// MARK: - FSUpdatable Default Implementation
extension FSUpdatable where ModelType: Decodable {
    
    // MARK: Update
    func updateModel(completion: @escaping ResultHandler<String>) {
        reference.getDocuments { [weak self] snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            self?.model.value = snapshot?.documents
                .compactMap { (document) -> ModelType? in
                    if let resultModel = try? document.data(as: ModelType.self) {
                        // Проверяем, если модель Identifiable - то задаем ей documentID
                        if var identifiableModel = resultModel as? FSIdentifiable {
                            identifiableModel.identifier = document.documentID
                            return identifiableModel as? ModelType
                        }
                        return resultModel
                    } else {
                        return nil
                    }
                } ?? [ModelType]()
            
            if let modelsUpdated = self?.model.value.count {
                completion(
                    .success("🔥 [FSUpdates] \(modelsUpdated) documents updated")
                )
            } else {
                completion(
                    .failure(FirestoreError.updatingError)
                )
            }
        }
    }
}
