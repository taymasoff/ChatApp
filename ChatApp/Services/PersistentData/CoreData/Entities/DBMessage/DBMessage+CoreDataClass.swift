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
    
    var formattedDate: String {
        if self.created.isToday() {
            return "Today"
        } else if self.created.isYesterday() {
            return "Yesterday"
        } else if self.created.isThisYear() {
            DateFormatter.shared.dateFormat = "MMMM d"
            return DateFormatter.shared.string(from: self.created)
        } else {
            DateFormatter.shared.dateFormat = "MMMM d, yyyy"
            return DateFormatter.shared.string(from: self.created)
        }
    }
    
    @objc
    var sectionName: String {
        return formattedDate
    }
}

// MARK: - To Domain Convertable
extension DBMessage: ManagedObjectModel {
    var uniqueSearchPredicate: NSPredicate? {
        return NSPredicate(format: "created == %@",
                           self.created as NSDate)
    }
    
    var uniqueSearchString: String? {
        return "\(created)"
    }
    
    func toDomainModel() -> Message {
        return Message(
            content: content,
            created: created,
            senderID: senderId,
            senderName: senderName
        )
    }
}
