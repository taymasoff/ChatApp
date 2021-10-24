//
//  Constants.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.10.2021.
//

import Foundation

let deviceID = UIDevice.current.identifierForVendor!.uuidString

/// Дефолтные названия файлов для полей
enum AppFileNames: String {
    case userName = "UserName"
    case userDescription = "UserDescription"
    case userAvatar = "UserAvatar"
}
