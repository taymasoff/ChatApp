//
//  CSModelUpdateLog.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 03.11.2021.
//

import Foundation

struct CSModelUpdateLog<ModelType: Codable> {
    var addedObjects: [ModelType] = []
    var updatedObjects: [ModelType] = []
    var removedObjects: [ModelType] = []
    
    var addedCount: Int {
        return addedObjects.count
    }
    
    var updatedCount: Int {
        return updatedObjects.count
    }
    
    var removedCount: Int {
        return removedObjects.count
    }
}
