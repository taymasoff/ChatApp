//
//  NSManagedObjectContext+obtainPermanentIDs.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 08.11.2021.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Присваивает постоянные ID insertнутым объектам контекста
    func obtainPermanentIDsForInsertedObjectsIfNeeded() throws {
        guard !self.insertedObjects.isEmpty else { return }
        do {
            try self.obtainPermanentIDs(for: Array(self.insertedObjects))
        } catch {
            throw CoreDataError.failedToObtainPermanentIDsForInsertedObjects
        }
    }
}
