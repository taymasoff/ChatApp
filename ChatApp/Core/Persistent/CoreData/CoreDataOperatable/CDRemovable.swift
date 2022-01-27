//
//  CDRemovable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов удаления в CoreData Context
protocol CDRemovable: CDOperatableBase {
    
    /// Удаляет NSManagedObject из контекста по его связанному доменному объекту
    func removeEntity(ofObject object: ModelType, completion: @escaping (Bool) -> Void)
    
    /// Удаляет все NSManagedObject типа Entity по предикату
    func removeAll(matching predicate: NSPredicate, completion: @escaping (Bool) -> Void)
    
    /// Удаляет все NSManagedObject подходящие по предикату, кроме тех, что переданы в параметр except. Возвращает количество удаленных элементов
    func removeAll(matching predicate: NSPredicate?,
                   except entities: [Entity],
                   completion: @escaping (Int) -> Void)
    
    /// Удаляет все NSManagedObject типа Entity в контексте с сохранением контекста после
    func removeAll(completion: @escaping ResultHandler<String>)
}

// MARK: - CDRemovable Default Implementation
extension CDRemovable where Self: CDFetchable {
    
    // MARK: Remove Object
    func removeEntity(ofObject object: ModelType, completion: @escaping (Bool) -> Void) {
        context.perform {
            if let entity = fetchEntity(ofObject: object) {
                context.delete(entity)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: Remove All matching predicate
    func removeAll(matching predicate: NSPredicate, completion: @escaping (Bool) -> Void) {
        context.perform {
            var deletedAny = false
            let entities = try? fetchEntities(matching: predicate, sortDescriptors: nil)
            entities?.forEach {
                context.delete($0)
                deletedAny = true
            }
            completion(deletedAny)
        }
    }
    
    // MARK: Remove All in predicate except passed entities
    func removeAll(matching predicate: NSPredicate? = nil,
                   except entities: [Entity],
                   completion: @escaping (Int) -> Void) {
        context.perform {
            guard let fetchedEntities = try? self.fetchEntities(matching: predicate) else {
                completion(0)
                return
            }
            var deletedCount = 0
            for entity in fetchedEntities {
                if !entities.contains(entity) {
                    self.context.delete(entity)
                    deletedCount += 1
                }
            }
            completion(deletedCount)
        }
    }
    
    // MARK: Remove All Entities
    func removeAll(completion: @escaping ResultHandler<String>) {
        context.perform {
            let batchDeleteRequest = NSBatchDeleteRequest(
                fetchRequest: Entity.fetchRequest()
            )
            batchDeleteRequest.resultType = .resultTypeCount
            
            do {
                let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                completion(
                    .success("🗄 [CoreData]: Deleted in the batch: \(String(describing: batchDeleteResult?.result))")
                )
            } catch {
                completion(.failure(error))
            }
        }
    }
}
