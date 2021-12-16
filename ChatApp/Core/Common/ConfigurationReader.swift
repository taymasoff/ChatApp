//
//  ConfigurationReader.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.12.2021.
//

import Foundation

/// Хелпер, который помогает доставать конфигурационные параметры из Info.plist файла
struct ConfigurationReader {
    private init() { }
    static let shared = ConfigurationReader()
    
    enum ConfigurationReaderError: Error {
        case failedToReadInfoPlistFile
        case failedToReadConfigurationDictionary
        case failedToReadConfigurationGroup(String)
        case failedToReadObjectByKey(String)
        case valueCantBePresentedAs(type: String)
    }
    
    enum ConfigurationGroup {
        case applicationGroup
        case fileManagerGroup
        case pixabayAPIGroup
        case unlistedGroup(String)
        
        var dictionaryName: String {
            switch self {
            case .applicationGroup:
                return "ApplicationConfiguration"
            case .fileManagerGroup:
                return "FileManagerConfiguration"
            case .pixabayAPIGroup:
                return "PixabayAPIConfiguration"
            case .unlistedGroup(let name):
                return name
            }
        }
    }
    
    /// Ищет значение в Info.plist файле
    /// - Parameters:
    ///   - inside: параметры в plist'е разделены по группам (словарям), необходимо передать сюда группу параметра
    ///   - byKey: ключ, по которому необходимо искать параметр в переданом в group словаре
    /// - Returns: Generic значение или ошибку
    func readValue<T>(
        inside group: ConfigurationGroup,
        byKey key: String
    ) throws -> T where T: LosslessStringConvertible {
        
        guard let plist = Bundle.main.infoDictionary else {
            throw ConfigurationReaderError.failedToReadInfoPlistFile
        }
        
        guard let configuration = plist["Configurations"] as? [String: [String: Any]] else {
            throw ConfigurationReaderError.failedToReadConfigurationDictionary
        }
        
        guard let configurationGroup = configuration[group.dictionaryName] else {
            throw ConfigurationReaderError.failedToReadConfigurationGroup(group.dictionaryName)
        }
        
        guard let object = configurationGroup[key] else {
            throw ConfigurationReaderError.failedToReadObjectByKey(key)
        }
        
        switch object {
        case let value as T:
            return value
        case let stringValue as String:
            guard let value = T(stringValue) else { fallthrough }
            return value
        default:
            throw ConfigurationReaderError
                .valueCantBePresentedAs(type: String(describing: T.self))
        }
    }
    
    /// Ищет значение в Info.plist файле, но без прокидывания ошибки. Если значение достать не получилось - вылетит fatalError
    /// - Returns: значение
    func readValueNoThrow<T>(
        inside group: ConfigurationGroup,
        byKey key: String
    ) -> T where T: LosslessStringConvertible {
        do {
            return try readValue(inside: group, byKey: key)
        } catch {
            fatalError("ConfigurationReader error: \(error.localizedDescription)")
        }
    }
}
