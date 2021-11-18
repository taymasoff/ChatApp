//
//  CodingError.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

// MARK: - Coding Errors
enum CodingError: Error {
    case imageDecodingError
    case imageEncodingError
    case jsonDecodingError
    case jsonEncodingError
    case nilValue
}
