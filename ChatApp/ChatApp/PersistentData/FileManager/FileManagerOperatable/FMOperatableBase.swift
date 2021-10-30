//
//  FMOperatableBase.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Базовый протокол для поддержки протоколов семейства FileManagerOperatable
protocol FMOperatableBase: FromDataConvertable, ToDataConvertable {
    var fileManager: AsyncFileManagerProtocol { get }
    var fmPreferences: FileManagerPreferences { get }
}
