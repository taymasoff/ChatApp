//
//  CoreDataStack.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

protocol CoreDataStackProtocol {
    var mainContext: NSManagedObjectContext { get }
    var newBackgroundContext: NSManagedObjectContext { get }
}

final class CoreDataStack: CoreDataStackProtocol {
    
    private init() { }
    
    static let shared = CoreDataStack()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var newBackgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppData.coreDataModel)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Persistent container initialization error: \(error),\(error.userInfo)")
            }
            
            #if DEBUG
            debugPrint(storeDescription.getDatabaseLocation() ?? "No database location")
            #endif
            
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
}

extension NSPersistentStoreDescription {
    
    /// Получить путь хранилища NSPersistentStore
    /// - Returns: путь к хранилищу в формате строки, удобной для чтения
    func getDatabaseLocation() -> String? {
        return self
            .url?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .replacingOccurrences(of: "%20", with: " ")
    }
}
