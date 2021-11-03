//
//  CDWorker.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import Foundation
import CoreData

final class CDWorker<
    Model: DomainModel,
    Entity: NSManagedObject & ToDomainModelConvertable
> where Model.Entity == Entity, Entity.DomainModel == Model {
    
    private let context: NSManagedObjectContext
    
    private var hasPersistentChanges: Bool {
        return !context.insertedObjects.isEmpty || !context.deletedObjects.isEmpty || context.updatedObjects.contains(where: { $0.hasPersistentChangedValues })
    }
    
    let coreDataManager: CoreDataManager<Model, Entity>
    
    init(context: NSManagedObjectContext,
         mergePolicy: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.context = context
        self.context.mergePolicy = NSMergePolicy(merge: mergePolicy)
        self.coreDataManager = CoreDataManager<Model, Entity>(context: context)
    }
    
    func saveIfNeeded(completion: @escaping (Bool) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        context.perform {
            let hasPurpose = self.context.parent != nil || self.context.persistentStoreCoordinator?.persistentStores.isEmpty == false
            guard self.hasPersistentChanges && hasPurpose else {
                completion(false)
                return
            }
            do {
                try self.context.save()
                let diff = CFAbsoluteTimeGetCurrent() - startTime
                print("🗄 [CoreData]: Saved some changes. Took \(diff) seconds to save!")
                completion(true)
            } catch {
                self.context.rollback()
                Log.error("🗄 [CoreData]: Failed to save context: \(error)")
                completion(false)
            }
        }
    }
}
