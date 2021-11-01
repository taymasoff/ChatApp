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
    
    // MARK: Compose an Update Log Method
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

// MARK: - CloudStore Subscribable
extension FirestoreManager: CloudStoreSubscribable where ModelType: Decodable {
    
    // MARK: Subscribe To Updates Method
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
