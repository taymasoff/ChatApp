//
//  CDInsertable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов вставки объекта в CoreData Context
protocol CDInserable: CDOperatableBase {
    
    /// Вставляет элементы типа ModelType во вью-контекст
    func insert(_ objects: [ModelType], completion: @escaping (Bool) -> Void)
    
    /// Вставляет 1 элемент типа ModelType во вью-контекст
    func insert(_ object: ModelType, completion: @escaping (Entity) -> Void)
}

// MARK: - CDInsertable Default Implementation
extension CDInserable where ModelType.Entity == Entity {
    
    // MARK: Insert Objects
    func insert(_ objects: [ModelType], completion: @escaping (Bool) -> Void) {
        context.perform {
            objects.forEach {
                let name = String(describing: Entity.self)
                let entityDescription = NSEntityDescription.entity(forEntityName: name,
                                                                   in: context)!
                let entity = Entity(entity: entityDescription, insertInto: context)
                $0.insertInto(entity: entity)
            }
            completion(true)
        }
    }
    
    // MARK: Insert Object
    func insert(_ object: ModelType, completion: @escaping (Entity) -> Void) {
        context.perform {
            let name = String(describing: Entity.self)
            let entityDescription = NSEntityDescription.entity(forEntityName: name,
                                                               in: context)!
            let entity = Entity(entity: entityDescription, insertInto: context)
            object.insertInto(entity: entity)
            completion(entity)
        }
    }
}
