//
//  Date+isThisYear.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import Foundation

internal extension Date {
    func isThisYear() -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let passedYear = calendar.component(.year, from: self)
        return passedYear == currentYear
    }
}
