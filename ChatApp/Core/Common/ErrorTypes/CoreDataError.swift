//
//  CoreDataError.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 02.11.2021.
//

import Foundation

enum CoreDataError: Error {
    case invalidDBType
    case fetchingFailed
    case failedToObtainPermanentIDsForInsertedObjects
}
