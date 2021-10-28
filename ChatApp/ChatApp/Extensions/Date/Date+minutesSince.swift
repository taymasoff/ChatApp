//
//  Date+minutesSince.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import Foundation

/*
 👉 Возвращает количество минут, прошедших данной даты
 📲 Пример вывода: "256"
 */

internal extension Date {
    func minutesSince() -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
    }
}
