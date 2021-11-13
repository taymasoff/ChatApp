//
//  DBMessage+CoreDataClass.swift
//  
//
//  Created by Тимур Таймасов on 02.11.2021.
//
//

import Foundation
import CoreData

@objc(DBMessage)
public class DBMessage: NSManagedObject {

}

// MARK: - To Domain Convertable
extension DBMessage: ToDomainModelConvertable {
    
    func toDomainModel() -> Message {
        return Message(
            content: content,
            created: created,
            senderID: senderId,
            senderName: senderName
        )
    }
}
