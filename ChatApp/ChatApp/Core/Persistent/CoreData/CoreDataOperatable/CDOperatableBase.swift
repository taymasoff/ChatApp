//
//  CDOperatableBase.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import CoreData

/// Базовый тип работы с CoreData
protocol CDOperatableBase {
    associatedtype ModelType: DomainModel
    associatedtype Entity: NSManagedObject & ManagedObjectModel
    
    var context: NSManagedObjectContext { get }
}
