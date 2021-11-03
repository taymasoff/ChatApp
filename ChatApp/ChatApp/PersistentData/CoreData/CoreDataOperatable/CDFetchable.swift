//
//  CDFetchable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Тип, представляющий поддержку методов поиска объекта в CoreData Context
protocol CDFetchable: CDOperatableBase {
    
    /// Получить список моделей NSManagedObject, соответствующих предикату и дескрипторам сортировки
    /// - Returns: массив типа NSManagedObject
    func fetchEntities(matching predicate: NSPredicate?,
                       sortDescriptors: [NSSortDescriptor]?) throws -> [Entity]
    
    /// Получить список моделей, соответствующих предикату и дескрипторам сортировки
    /// - Returns: массив типа объекта
    func fetchObjects(matching predicate: NSPredicate?,
                      sortDescriptors: [NSSortDescriptor]?) throws -> [ModelType]
    
    /// Получить первую модель NSManagedObject, соответствующую предикату
    /// - Returns: опциональную модель NSManagedObject
    func fetchFirstEntity(matching predicate: NSPredicate) throws -> Entity?
    
    /// Получить первую модель, соответствующую предикату
    /// - Returns: опциональную модель
    func fetchFirstObject(matching predicate: NSPredicate) throws -> ModelType?
    
    /// Получить модель типа NSManagedObject, соответствующую уникальному идентификатору
    /// - Returns: опциональную модель
    func fetchEntity(withID id: String) -> Entity?
    
    /// Получить модель, соответствующую уникальному идентификатору
    /// - Returns: опциональную модель
    func fetchObject(withID id: String) -> ModelType?
}

// MARK: - CDFetchable Default Implementation
extension CDFetchable {
    
    // MARK: FetchEntities matching predicate and sortDescriptors
    func fetchEntities(matching predicate: NSPredicate?,
                       sortDescriptors: [NSSortDescriptor]?) throws -> [Entity] {
        
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(fetchRequest) as? [Entity] ?? []
        } catch {
            throw CoreDataError.fetchingFailed
        }
    }
    
    // MARK: FetchObjects matching predicate and sortDescriptors
    func fetchObjects(matching predicate: NSPredicate?,
                      sortDescriptors: [NSSortDescriptor]?) throws -> [ModelType] {
        
        do {
            return try fetchEntities(matching: predicate, sortDescriptors: sortDescriptors)
                .compactMap { $0.toDomainModel() as? ModelType }
        } catch {
            throw CoreDataError.fetchingFailed
        }
        
    }
    
    // MARK: FetchFirstEntity matching predicate
    func fetchFirstEntity(matching predicate: NSPredicate) throws -> Entity? {
        
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let entity = try context.fetch(fetchRequest) as? [Entity]
            return entity?.first
        } catch {
            throw CoreDataError.fetchingFailed
        }
    }
    
    // MARK: FetchFirstObject matching predicate
    func fetchFirstObject(matching predicate: NSPredicate) throws -> ModelType? {
        
        do {
            let entity = try fetchFirstEntity(matching: predicate)
            return entity?.toDomainModel() as? ModelType
        } catch {
            throw CoreDataError.fetchingFailed
        }
    }
    
    // MARK: FetchEntity with ID
    func fetchEntity(withID id: String) -> Entity? {
        let predicate = NSPredicate(format: "identifier == %@", id)
        return try? fetchFirstEntity(matching: predicate)
    }
    
    // MARK: FetchObject with ID
    func fetchObject(withID id: String) -> ModelType? {
        return fetchEntity(withID: id)?.toDomainModel() as? ModelType
    }
}
