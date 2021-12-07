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
    
    @objc
    var isActive: Bool {
        if let lastActivity = lastActivity {
            return lastActivity.minutesSince() < 10
        } else {
            return false
        }
    }
    
    @objc
    var sectionName: String {
        return isActive ? "Active Conversations" : "Inactive Conversations"
    }
}

// MARK: - ManagedObjectModel
extension DBChannel: ManagedObjectModel {
    var uniqueSearchPredicate: NSPredicate? {
        return NSPredicate(format: "identifier == %@", identifier)
    }
    
    var uniqueSearchString: String? {
        return identifier
    }
    
    func toDomainModel() -> Conversation {
        return Conversation(
            identifier: identifier,
            name: name,
            lastMessage: lastMessage,
            lastActivity: lastActivity
        )
    }
}
