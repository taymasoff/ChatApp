//
//  DataRemovable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Тип, представляющий возможность удаления записи по ключу
protocol DataRemovable {
    func removeRecord(key: String, completion: @escaping CompletionHandler<Bool>)
}
