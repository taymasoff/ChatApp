//
//  PersistenceManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import UIKit

/*
 👉 Данный файл является посредником между объектом реализации хранения данных и пользовательскими данными, тут проходят все необходимые форматирования и надстройки, при инициализации задаются необходимые параметры.
 */

/// Тип локального хранилища
enum StorageType {
    case userDefaults(UserDefaults)
    case fileManger(AsyncFileManagerProtocol, FileManagerPreferences)
}

/// Пакет предпочитаемых настроек для работы с файловым менеджером
struct FileManagerPreferences {
    enum TextExtension: String {
        case txt = "txt"
        case json = "json"
    }
    
    enum ImageExtension: String {
        case png = "png"
        case jpeg = "jpeg"
    }
    
    private(set) var preferredTextExtension: TextExtension
    private(set) var preferredImageExtension: ImageExtension
    private(set) var preferredDirectory: FMDirectory
}

/// Менеджер работы с локальными данными
class PersistenceManager {
    let storageType: StorageType
    
    init(storageType: StorageType = .userDefaults(UserDefaults.standard)) {
        self.storageType = storageType
    }
}

// MARK: - PersistenceManagerProtocol
extension PersistenceManager: PersistenceManagerProtocol {
    func fetchString(key: String, completion: @escaping CompletionHandler<String>) {
        switch storageType {
        // MARK: FetchString - UserDefaults
        case .userDefaults(let defaults):
            if let data = defaults.data(forKey: key) {
                completion(
                    .success(convertToString(data))
                )
            }
        // MARK: FetchString - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + "." + pref.preferredTextExtension.rawValue
            fm.read(fromFileNamed: fullFileName,
                    at: pref.preferredDirectory) { [weak self] result in
                guard let self = self else {
                    completion(.failure(PMError.nilValue))
                    return
                }
                switch result {
                case .success(let data):
                    let str = self.convertToString(data)
                    completion(.success(str))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchImage(key: String, completion: @escaping CompletionHandler<UIImage>) {
        switch storageType {
        // MARK: FetchImage - UserDefaults
        case .userDefaults(let defaults):
            if let data = defaults.data(forKey: key) {
                do {
                    let image = try convertToImage(data)
                    completion(.success(image))
                } catch {
                    completion(.failure(error))
                }
            }
        // MARK: FetchImage - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + "." + pref.preferredImageExtension.rawValue
            fm.read(fromFileNamed: fullFileName,
                    at: pref.preferredDirectory) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let self = self else {
                        completion(.failure(PMError.nilValue))
                        return
                    }
                    do {
                        let image = try self.convertToImage(data)
                        completion(.success(image))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchModel<T: Decodable>(key: String, completion: @escaping CompletionHandler<T>) {
        switch storageType {
        // MARK: FetchModel - UserDefaults
        case .userDefaults(let defaults):
            if let data = defaults.data(forKey: key) {
                do {
                    completion(
                        .success(try convertToModel(data))
                    )
                } catch {
                    completion(.failure(error))
                }
            }
        // MARK: FetchModel - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + ".json"
            fm.read(fromFileNamed: fullFileName,
                    at: pref.preferredDirectory) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let self = self else {
                        completion(.failure(PMError.nilValue))
                        return
                    }
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
    }
    
    func save(_ string: String, key: String, completion: @escaping CompletionHandler<Bool>) {
        switch storageType {
        // MARK: SaveString - UserDefaults
        case .userDefaults(let defaults):
            let data = convertToData(string)
            defaults.set(data, forKey: key)
            completion(.success(true))
        // MARK: SaveString - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + "." + pref.preferredTextExtension.rawValue
            let data = convertToData(string)
            fm.write(data: data,
                     inFileNamed: fullFileName,
                     at: pref.preferredDirectory) { result in
                switch result {
                case .success(let isSuccessful):
                    completion(.success(isSuccessful))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func save(_ image: UIImage,
              key: String,
              completion: @escaping CompletionHandler<Bool>) {
        switch storageType {
        // MARK: SaveImage - UserDefaults
        case .userDefaults(let defaults):
            do {
                let data = try convertToData(image)
                defaults.set(data, forKey: key)
                completion(.success(true))
            } catch {
                completion(.failure(CodingError.imageEncodingError))
            }
        // MARK: SaveImage - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + "." + pref.preferredImageExtension.rawValue
            do {
                let data = try convertToData(image)
                fm.write(data: data,
                         inFileNamed: fullFileName,
                         at: pref.preferredDirectory) { result in
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
    
    func save<T: Encodable>(_ model: T,
                            key: String,
                            completion: @escaping CompletionHandler<Bool>) {
        switch storageType {
        // MARK: SaveModel - UserDefaults
        case .userDefaults(let defaults):
            do {
                let data = try convertToData(model)
                defaults.set(data, forKey: key)
                completion(.success(true))
            } catch {
                completion(.failure(CodingError.jsonEncodingError))
            }
        // MARK: SaveModel - FileManager
        case .fileManger(let fm, let pref):
            let fullFileName = key + ".json"
            do {
                let data = try convertToData(model)
                fm.write(data: data,
                         inFileNamed: fullFileName,
                         at: pref.preferredDirectory) { result in
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
}