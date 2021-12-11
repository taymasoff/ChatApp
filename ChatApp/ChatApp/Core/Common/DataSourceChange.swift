//
//  DataSourceChange.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 10.11.2021.
//

import Foundation

enum DataSourceChange {
    enum SectionUpdate {
        case inserted(Int)
        case deleted(Int)
    }
    
    enum ObjectUpdate {
        case inserted(at: IndexPath)
        case deleted(from: IndexPath)
        case updated(at: IndexPath)
        case moved(from: IndexPath, to: IndexPath)
    }
    
    case section(SectionUpdate)
    case object(ObjectUpdate)
}
