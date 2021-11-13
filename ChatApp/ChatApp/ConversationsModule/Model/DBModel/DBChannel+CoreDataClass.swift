//
//  DBChannel+CoreDataClass.swift
//  
//
//  Created by Тимур Таймасов on 02.11.2021.
//
//

import Foundation
import CoreData

@objc(DBChannel)
public class DBChannel: NSManagedObject {

}

// MARK: - To Domain Convertable
extension DBChannel: ToDomainModelConvertable {
    
    func toDomainModel() -> Conversation {
        return Conversation(
            identifier: identifier,
            name: name,
            lastMessage: lastMessage,
            lastActivity: lastActivity
        )
    }
}
