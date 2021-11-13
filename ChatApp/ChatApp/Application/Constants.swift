//
//  Constants.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.10.2021.
//

import UIKit

/// Дефолтные названия файлов для полей
enum AppFileNames: String {
    case userName = "UserName"
    case userDescription = "UserDescription"
    case userAvatar = "UserAvatar"
}

/// Имена коллекций Firebase
enum FBCollections: String {
    case channels
    case messages
}

/// Данные приложения
struct AppData {
    private init() {}
    
    static let defaultUserName = "Unauthorized"
    
    @Stored(key: AppFileNames.userName.rawValue, defaultValue: Self.defaultUserName)
    static var currentUserName: String
    
    static var deviceID: String = UIDevice.current.identifierForVendor!.uuidString
}
