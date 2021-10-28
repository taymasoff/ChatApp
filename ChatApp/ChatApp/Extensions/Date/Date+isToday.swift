//
//  Date+isToday.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import Foundation

internal extension Date {
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
}
