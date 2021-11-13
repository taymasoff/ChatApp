//
//  DBIdentifiable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation

/// Тип, указывающий на то, что объект имеет свойство identifier
protocol DBIdentifiable {
    var identifier: String? { get set }
}
