//
//  FSSubscribable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation
import FirebaseFirestore

typealias FSUpdatesListener = (_ updateLog: String?, _ error: Error?) -> Void

/// Тип, представляющий поддержку работы Firestore с методами подписки/отписки от уведомлений
protocol FSSubscribable: FSOperatableBase {
    
    /// Переменная, необходимая для возможности удаления подписки
    var listener: ListenerRegistration? { get set }
    
    /// Подписывается на обновления reference и обновляет model при любом изменении
    /// - Parameters:
    /// - listener: замыкание, принимающее опциональный список изменений updateLog или ошибку error
    /// - updateLog: оцпиональная строка, содержащая в себе список изменений
    /// - error: опциональный Error
    func subscribeToUpdates(listener: @escaping FSUpdatesListener)
    
    /// Отписывается от обновлений reference
    func unsubscribeFromUpdates()
}

// MARK: - FSSubscribable Default Implementation
extension FSSubscribable where ModelType: Decodable {
    
    // MARK: SubscribeToUpdates Default Implementation
    func subscribeToUpdates(listener: @escaping FSUpdatesListener) {
        self.listener = reference.addSnapshotListener { [weak self] snapshot, error in
            guard error == nil else {
                listener(nil, error)
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
            
            listener(
                self?.composeUpdateLog(snapshot: snapshot),
                nil
            )
        }
    }
    
    // MARK: UnsubscribeFromUpdates Default Implementation
    func unsubscribeFromUpdates() {
        _ = listener?.remove()
    }
    
    // MARK: Compose an Update Log
    private func composeUpdateLog(snapshot: QuerySnapshot?) -> String? {
        // Считаем изменения и выводим их количество
        return snapshot?.documentChanges.reduce(into: [String: Int](), { dict, change in
            if change.type == .added {
                dict["added", default: 0] += 1
            }
            if change.type == .modified {
                dict["modified", default: 0] += 1
            }
            if change.type == .removed {
                dict["removed", default: 0] += 1
            }
        }).compactMap {
            return "🔥 [FSUpdates] Documents \($0.key): \($0.value)"
        }.joined(separator: "\n")
    }
}
