//
//  CoreDataManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import Foundation
import CoreData

typealias CoreDataOperatable = CDFetchable & CDInserable & CDUpdatable & CDRemovable

protocol CoreDataManagerProtocol: CoreDataOperatable { }

final class CoreDataManager<
    ModelType: DomainModel,
    Entity: NSManagedObject & ManagedObjectModel
>: CoreDataManagerProtocol where Entity.DomainModel == ModelType,
                                 ModelType.Entity == Entity {
    typealias ModelType = ModelType
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
