//
//  Date+isYesterday.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import Foundation

internal extension Date {
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
}
