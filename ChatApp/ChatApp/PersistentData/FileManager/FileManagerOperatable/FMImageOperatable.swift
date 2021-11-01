//
//  FMImageOperatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import UIKit

/// Тип, представляющий поддержку работы файлового менеджера с изображениями
protocol FMImageOperatable: FMOperatableBase, ImageSaveable, ImageFetchable { }

// MARK: - FMImageOperatable Default Implementation
extension FMImageOperatable {
    
    // MARK: Fetch Image Default Implementation
    func fetchImage(key: String, completion: @escaping ResultHandler<UIImage>) {
        let prefImageExtension = fmPreferences.preferredImageExtension
        let fullFileName = key.appending(prefImageExtension.fileExtension)
        fileManager.read(fromFileNamed: fullFileName,
                         at: fmPreferences.preferredDirectory) { result in
            switch result {
            case .success(let data):
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
    
    // MARK: Save Image Default Implementation
    func save(_ image: UIImage, key: String, completion: @escaping ResultHandler<Bool>) {
        let prefImageExtension = fmPreferences.preferredImageExtension
        let fullFileName = key.appending(prefImageExtension.fileExtension)
        
        do {
            let data = try getDataFrom(image: image, using: prefImageExtension)
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
    
    // MARK: Get Data From Image depending on preferred image extension
    private func getDataFrom(image: UIImage, using pref: ImageExtension) throws -> Data {
        switch pref {
        case .png:
            return try convertToData(image, as: .png)
        case .jpeg(let compression):
            return try convertToData(image, as: .jpeg(compression))
        }
    }
}

// MARK: - Optional Image Support -> Delete File If nil
extension FMImageOperatable where Self: FMRemoveSupportable {
    // MARK: - Save Optional String
    func save(_ image: UIImage?, key: String, completion: @escaping ResultHandler<Bool>) {
        if let image = image {
            save(image, key: key, completion: completion)
        } else {
            let keyWithExtension = key.appending(
                fmPreferences.preferredImageExtension.fileExtension
            )
            removeRecord(keyWithExtension: keyWithExtension, completion: completion)
        }
    }
}
