//
//  FMModelOperatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, представляющий поддержку работы файлового менеджера с моделями Codable моделями данных
protocol FMModelOperatable: FMOperatableBase, ModelSaveable, ModelFetchable { }

// MARK: - FMModelOperatable Default Implementation
extension FMModelOperatable {

    // MARK: Fetch Model Default Implementation
    func fetchModel<T>(key: String,
                       completion: @escaping ResultHandler<T>) where T: Decodable {
        let fullFileName = key + ".json"
        fileManager.read(fromFileNamed: fullFileName,
                         at: fmPreferences.preferredDirectory) { result in
            switch result {
            case .success(let data):
                do {
                    completion(
                        .success(try self.convertToModel(data))
                    )
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Save Model Default Implementation
    func save<T>(_ model: T, key: String,
                 completion: @escaping ResultHandler<Bool>) where T: Encodable {
        let fullFileName = key + ".json"
        do {
            let data = try convertToData(model)
            fileManager.write(data: data,
                              inFileNamed: fullFileName,
                              at: fmPreferences.preferredDirectory) { result in
                switch result {
                case .success(let isSuccessful):
                    completion(.success(isSuccessful))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Optional Model Support -> Delete File If nil
extension FMImageOperatable where Self: FMRemoveSupportable {
    // MARK: - Save Optional String
    func save<T>(_ model: T?, key: String,
                 completion: @escaping ResultHandler<Bool>) where T: Encodable {
        if let model = model {
            save(model, key: key, completion: completion)
        } else {
            let keyWithExtension = key.appending(".json")
            removeRecord(keyWithExtension: keyWithExtension, completion: completion)
        }
    }
}
