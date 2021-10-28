//
//  GroupedMessages.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import Foundation

/// Модель сгруппированных сообщений. Используется для группировки по секциям.
struct GroupedMessages {
    let date: Date
    var messages: [Message]
    
    var numberOfItems: Int {
        return messages.count
    }

    subscript(index: Int) -> Message {
        return messages[index]
    }
}

// MARK: - Get Formatted Date
extension GroupedMessages {
    func getFormattedDate(_ formatter: DateFormatter) -> String {
        if self.date.isToday() {
            return "Today"
        } else if self.date.isYesterday() {
            return "Yesterday"
        } else if self.date.isThisYear() {
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: self.date)
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: self.date)
        }
    }
}
