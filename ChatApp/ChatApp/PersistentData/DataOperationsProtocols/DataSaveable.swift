//
//  DataSaveable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import UIKit

/// Тип, представляющий возможность сохранения строки, картинки и модели по ключу
typealias DataSaveable = StringSaveable & ImageSaveable & ModelSaveable

/// Тип, представляющий возможность сохранения строки по ключу
protocol StringSaveable {
    func save(_ string: String, key: String,
              completion: @escaping CompletionHandler<Bool>)
}

/// Тип, представляющий возможность сохранения изображения по ключу
protocol ImageSaveable {
    func save(_ image: UIImage, key: String,
              completion: @escaping CompletionHandler<Bool>)
}

/// Тип, представляющий возможность сохранения Encodable модели по ключу
protocol ModelSaveable {
    func save<T: Encodable>(_ model: T, key: String,
                            completion: @escaping CompletionHandler<Bool>)
}
