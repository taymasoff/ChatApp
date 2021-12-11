//
//  CDUpdatable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов обновления объекта в CoreData Context
protocol CDUpdatable: CDOperatableBase {
    // Может быть разная логика по обновлению: например нужно еще установить зависимость -
    // поэтому есть возможность предоставить эту логику тому, кто вызывает метод
    typealias UpdateBlock = (_ object: ModelType, _ entity: Entity) -> Entity
    
    /// Обновляет элементы типа ModelType во вью-контексте
    func update(_ objects: [ModelType],
                updateBlock: UpdateBlock?,
                insertIfNotExists: Bool,
                completion: @escaping (Int) -> Void)
    
    /// Обновляет элемент типа ModelType во вью-контексте
    func update(_ object: ModelType,
                updateBlock: UpdateBlock?,
                insertIfNotExists: Bool,
                completion: @escaping (Bool) -> Void)
}

// MARK: - CDUpdatable Default Implementation
extension CDUpdatable where Self: CDFetchable & CDInserable, ModelType.Entity == Entity {
    
    // MARK: Update Objects
    func update(
        _ objects: [ModelType],
        updateBlock: UpdateBlock? = nil,
        insertIfNotExists: Bool = true,
        completion: @escaping (Int) -> Void
    ) {
        context.perform {
            var objectsUpdated = 0
            let updateBlock = updateBlock ?? defaultUpdateLogic
            context.performAndWait {
                for object in objects {
                    if let entity = fetchEntity(ofObject: object) {
                        _ = updateBlock(object, entity)
                        objectsUpdated += 1
                    } else if insertIfNotExists {
                        insert(object) { entity in
                            _ = updateBlock(object, entity)
                        }
                        objectsUpdated += 1
                    }
                }
            }
            completion(objectsUpdated)
        }
    }
    
    // MARK: Update Object
    func update(
        _ object: ModelType,
        updateBlock: UpdateBlock? = nil,
        insertIfNotExists: Bool = true,
        completion: @escaping (Bool) -> Void
    ) {
        update([object],
               updateBlock: updateBlock,
               insertIfNotExists: insertIfNotExists) { completedAmout in
            completedAmout == 1 ? completion(true) : completion(false)
        }
    }
    
    private func defaultUpdateLogic(_ model: ModelType, _ entity: Entity) -> Entity {
        return model.insertInto(entity: entity)
    }
}
