//
//  FMStringOperatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, представляющий поддержку работы файлового менеджера с текстом
protocol FMStringOperatable: FMOperatableBase, StringSaveable, StringFetchable { }

// MARK: - FMStringOperatable StringSaveable Default Implementation
extension FMStringOperatable {
    
    // MARK: Fetch String Default Implementation
    func fetchString(key: String, completion: @escaping ResultHandler<String>) {
        let fullFileName = key.appending(fmPreferences.preferredTextExtension.fileExtension)
        fileManager.read(fromFileNamed: fullFileName,
                         at: fmPreferences.preferredDirectory) { result in
            switch result {
            case .success(let data):
                let str = self.convertToString(data)
                completion(.success(str))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Save String Default Implementation
    func save(_ string: String, key: String, completion: @escaping ResultHandler<Bool>) {
        let fullFileName = key + "." + "txt"
        let data = convertToData(string)
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
    }
}

// MARK: - Optional String Support -> Delete File If nil
extension FMStringOperatable where Self: FMRemoveSupportable {
    // MARK: - Save Optional String
    func save(_ string: String?, key: String, completion: @escaping ResultHandler<Bool>) {
        if let string = string, string != "" {
            save(string, key: key, completion: completion)
        } else {
            let keyWithExtension = key.appending(
                fmPreferences.preferredTextExtension.fileExtension
            )
            removeRecord(keyWithExtension: keyWithExtension, completion: completion)
        }
    }
}
