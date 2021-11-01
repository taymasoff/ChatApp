//
//  DataFetchable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import UIKit

/// Тип, представляющий возможность получения строки, картинки и модели по ключу
typealias DataFetchable = StringFetchable & ImageFetchable & ModelFetchable

/// Тип, представляющий возможность получения строки по ключу
protocol StringFetchable {
    func fetchString(key: String, completion: @escaping ResultHandler<String>)
}

/// Тип, представляющий возможность получения картинки по ключу
protocol ImageFetchable {
    func fetchImage(key: String, completion: @escaping ResultHandler<UIImage>)
}

/// Тип, представляющий возможность получения модели по ключу
protocol ModelFetchable {
    func fetchModel<T: Decodable>(key: String, completion: @escaping ResultHandler<T>)
}
