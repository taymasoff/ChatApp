//
//  CDUpdatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов обновления объекта в CoreData Context
protocol CDUpdatable: CDOperatableBase {
    
    /// Обновляет элементы типа ModelType во вью-контексте
    func update(_ objects: [ModelType], completion: @escaping (Bool) -> Void)
    
    /// Обновляет элемент типа ModelType во вью-контексте
    func update(_ object: ModelType, completion: @escaping (Entity) -> Void)
}

// MARK: - CDUpdatable Default Implementation
extension CDUpdatable where Self: CDInserable {
    
    /*
     Пока не уверен, как мне идентифицировать объекты без уникальных полей.
     На данный момент хватает insert с mergePolicy
     */
    
    // MARK: Update Objects
    func update(_ objects: [ModelType], completion: @escaping (Bool) -> Void) {
        print("🗄 [CoreData]: Update is not implemented yet, using insert instead!")
        insert(objects, completion: completion)
    }
    
    // MARK: Update Object
    func update(_ object: ModelType, completion: @escaping (Entity) -> Void) {
        print("🗄 [CoreData]: Update is not implemented yet, using insert instead!")
        insert(object, completion: completion)
    }
}
