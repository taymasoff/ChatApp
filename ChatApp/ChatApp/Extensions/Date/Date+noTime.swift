//
//  Date+noTime.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import Foundation

/*
 👉 Вырезает время из даты
 */

internal extension Date {
    
    /// Функция по вырезанию компонентов времени из даты
    /// - Returns: дату без времени (год месяц день)
    func noTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }

}
