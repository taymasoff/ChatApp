//
//  Constants.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.10.2021.
//

import Foundation

/// Дефолтные названия файлов для полей
enum AppFileNames: String {
    case userName
    case userDescription
    case userAvatar
    
    var rawValue: String {
        switch self {
        case .userName:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .fileManagerGroup,
                byKey: "userNameFileName"
            )
        case .userDescription:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .fileManagerGroup,
                byKey: "userDescriptionFileName"
            )
        case .userAvatar:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .fileManagerGroup,
                byKey: "userAvatarFileName"
            )
        }
    }
}

/// Имена коллекций Firebase
enum FBCollections: String {
    case channels
    case messages
}

/// Данные приложения
struct AppData {
    private init() {}
    
    static let defaultUserName: String = ConfigurationReader.shared.readValueNoThrow(
        inside: .applicationGroup,
        byKey: "defaultUserName"
    )
    
    @Stored(key: AppFileNames.userName.rawValue, defaultValue: Self.defaultUserName)
    static var currentUserName: String
    
    static var deviceID: String = UIDevice.current.identifierForVendor!.uuidString
    
    static let coreDataModel: String = "ChatAppDataModel"
}

/// Константы для работы с сервисом Pixabay
enum PixabayConfig: String {
    case baseURL
    case basePath
    case token
    
    var rawValue: String {
        switch self {
        case .baseURL:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .pixabayAPIGroup,
                byKey: "baseURL"
            )
        case .basePath:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .pixabayAPIGroup,
                byKey: "basePath"
            )
        case .token:
            return ConfigurationReader.shared.readValueNoThrow(
                inside: .pixabayAPIGroup,
                byKey: "token"
            )
        }
    }
}
