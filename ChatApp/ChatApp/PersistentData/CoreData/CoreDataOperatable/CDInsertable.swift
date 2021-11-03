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
    func insert(_ objects: [ModelType])
    
    /// Вставляет 1 элемент типа ModelType во вью-контекст
    @discardableResult
    func insert(_ object: ModelType) -> Entity
}

// MARK: - CDInsertable Default Implementation
extension CDInserable where ModelType.Entity == Entity {
    
    // MARK: Insert Objects
    func insert(_ objects: [ModelType]) {
    
        objects.forEach {
            insert($0)
        }
    }
    
    // MARK: Insert Object
    @discardableResult
    func insert(_ object: ModelType) -> Entity {
        let name = String(describing: Entity.self)
        let entityDescription = NSEntityDescription.entity(forEntityName: name,
                                                           in: context)!
        let entity = Entity(entity: entityDescription, insertInto: context)
        object.insertInto(entity: entity)
        return entity
    }
}
