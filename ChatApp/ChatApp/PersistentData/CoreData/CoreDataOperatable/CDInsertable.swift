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
    func insert(_ object: ModelType)
}

// MARK: - CDInsertable Default Implementation
extension CDInserable where ModelType.Entity == Entity {
    
    // MARK: Insert Objects
    func insert(_ objects: [ModelType]) {
    
        objects.forEach {
            let entity = Entity(context: context)
            $0.insertInto(entity: entity)
        }
    }
    
    // MARK: Insert Object
    func insert(_ object: ModelType) {
        insert([object])
    }
}
