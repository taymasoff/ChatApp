//
//  CDRemovable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов удаления в CoreData Context
protocol CDRemovable: CDOperatableBase {
    
    /// Удаляет NSManagedObject из контекста по его универсальному id
    func removeEntity(withID id: String) -> Bool
    
    /// Удаляет все NSManagedObject типа Entity по предикату
    func removeAll(matching predicate: NSPredicate) -> Bool
    
    /// Удаляет все NSManagedObject типа Entity в контексте с сохранением контекста после
    func removeAllAndSave(completion: @escaping ResultHandler<String>)
}

// MARK: - CDRemovable Default Implementation
extension CDRemovable where Self: CDFetchable {
    
    // MARK: Remove Object
    func removeEntity(withID id: String) -> Bool {
        let predicate = NSPredicate(format: "identifier = %@", id)
        if let entity = try? fetchFirstEntity(matching: predicate) {
            context.delete(entity)
            return true
        } else {
            return false
        }
    }
    
    // MARK: Remove All matching predicate
    func removeAll(matching predicate: NSPredicate) -> Bool {
        var deletedAny = false
        let entities = try? fetchEntities(matching: predicate, sortDescriptors: nil)
        entities?.forEach {
            context.delete($0)
            deletedAny = true
        }
        return deletedAny
    }
    
    // MARK: Remove All Entities
    func removeAllAndSave(completion: @escaping ResultHandler<String>) {
        let batchDeleteRequest = NSBatchDeleteRequest(
            fetchRequest: Entity.fetchRequest()
        )
        batchDeleteRequest.resultType = .resultTypeCount
        
        do {
            let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            try context.save()
            context.reset()
            completion(
                .success("🗄 [CoreData]: Deleted in the batch: \(String(describing: batchDeleteResult?.result))")
            )
        } catch {
            completion(.failure(error))
        }
    }
}
