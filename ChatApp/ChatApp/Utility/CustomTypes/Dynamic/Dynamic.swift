//
//  Dynamic.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 30.09.2021.
//

import Foundation

/// Обертка для байндинга,
///  .value для доступа к переменной, .bind для привязки
class Dynamic<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    let id: String
    
    init(_ value: T, id: String? = nil) {
        self.value = value
        
        self.id = id ?? UUID().uuidString
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
