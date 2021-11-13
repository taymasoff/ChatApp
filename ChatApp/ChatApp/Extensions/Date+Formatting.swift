//
//  Date+Formatting.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import Foundation

/*
 👉 Содержит расширения по форматированию вывода даты
 */

extension Date {
    
    // MARK: Time Since
    func timeSince() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            return "just now"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) minutes ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hours ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
    
    // MARK: Minutes Since
    func minutesSince() -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
    }
    
    // MARK: No Time
    /// Функция по вырезанию компонентов времени из даты
    /// - Returns: дату без времени (год месяц день)
    func noTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    // MARK: Is Today
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // MARK: Is Yesterday
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    // MARK: Is this Year
    func isThisYear() -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let passedYear = calendar.component(.year, from: self)
        return passedYear == currentYear
    }
}
