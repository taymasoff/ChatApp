//
//  DateFormatter+shared.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import Foundation

extension DateFormatter {
    static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
}
