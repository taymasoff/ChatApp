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
    
    @discardableResult public func saveIfNeeded() -> Bool {
        let hasPurpose = context.parent != nil || context.persistentStoreCoordinator?.persistentStores.isEmpty == false
        guard hasPersistentChanges && hasPurpose else {
            return false
        }
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            try context.save()
            let diff = CFAbsoluteTimeGetCurrent() - startTime
            print("🗄 [CoreData]: Saved some changes. Took \(diff) seconds to save!")
            return true
        } catch {
            context.rollback()
            Log.error("🗄 [CoreData]: Failed to save context: \(error)")
            return false
        }
    }
}
