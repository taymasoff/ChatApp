//
//  FirestoreManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import FirebaseFirestore

typealias CloudStoreProtocol = DynamicModelBasedCloudStore & CloudStoreSubscribable & CloudStoreAddable & CloudStoreRemovable & CloudStoreUpdatable

final class FirestoreManager<T: Codable>: DynamicModelBasedCloudStore {
    
    // MARK: - Properties
    let db: Firestore
    var reference: CollectionReference
    private var listener: ListenerRegistration?
    
    var model: Dynamic<[T]> = Dynamic([])
    
    // MARK: - Initializers
    init(database: Firestore?, reference: CollectionReference) {
        if let database = database {
            self.db = database
        } else {
            self.db = Firestore.firestore()
        }
        self.reference = reference
    }
    
    // MARK: Init with Collection Name
    convenience init(database: Firestore = Firestore.firestore(),
                     collectionName: String) {
        let reference = database.collection(collectionName)
        self.init(database: database, reference: reference)
    }
    
    // MARK: Map Document To Model
    private func mapDocumentToModel(document: QueryDocumentSnapshot) -> ModelType? {
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
    }
    
    // MARK: Compose an Update Log Method
    private func composeUpdateLog(snapshot: QuerySnapshot?) -> CSModelUpdateLog<T> {
        // Разбиваем изменения на 3 группы: Added/Modified/Removed, вписываем список
        // каждой группы в updateLog
        var updateLog = CSModelUpdateLog<T>()
        snapshot?.documentChanges.forEach { [weak self] diff in
            if diff.type == .added {
                if let model = self?.mapDocumentToModel(document: diff.document) {
                    updateLog.addedObjects.append(model)
                }
            }
            if diff.type == .modified {
                if let model = self?.mapDocumentToModel(document: diff.document) {
                    updateLog.updatedObjects.append(model)
                }
            }
            if diff.type == .removed {
                if let model = self?.mapDocumentToModel(document: diff.document) {
                    updateLog.removedObjects.append(model)
                }
            }
        }
        return updateLog
    }
}

// MARK: - CloudStore Subscribable
extension FirestoreManager: CloudStoreSubscribable where ModelType: Decodable {
    
    func subscribeToUpdates(enableLogging: Bool,
                            listener: @escaping ResultHandler<CSModelUpdateLog<ModelType>?>) {
        self.listener = reference.addSnapshotListener { [weak self] snapshot, error in
            // Сначала проверяем ошибку
            if let error = error {
                listener(.failure(error))
                return
            }
            
            // Обновляем модель
            self?.model.value = snapshot?.documents
                .compactMap { (document) -> ModelType? in
                    return self?.mapDocumentToModel(document: document)
                } ?? [ModelType]()
            
            // Если включено логирование, создаем и возвращаем CSModelUpdateLog
            guard enableLogging else { listener(.success(nil)); return }
            listener(.success(
                self?.composeUpdateLog(snapshot: snapshot)
            ))
        }
    }
    
    // MARK: Unsubscribe From Updates Method
    func unsubscribeFromUpdates() {
        _ = listener?.remove()
    }
}

// MARK: - CloudStore Updatable
extension FirestoreManager: CloudStoreUpdatable {
    
    // MARK: Update Model Method
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
                        if var identifiableModel = resultModel as? DBIdentifiable {
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

// MARK: - CloudStore Addable
extension FirestoreManager: CloudStoreAddable {
    
    // MARK: Add Entity Method
    func addEntity(from model: T, completion: (Result<String, Error>) -> Void) {
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

// MARK: - CloudStore Removable
extension FirestoreManager: CloudStoreRemovable {
    
    // MARK: Delete Entity Method
    func deleteEntity(withID id: String, completion: @escaping ResultHandler<String>) {
        reference.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Документ успешно удален"))
            }
        }
    }
}
