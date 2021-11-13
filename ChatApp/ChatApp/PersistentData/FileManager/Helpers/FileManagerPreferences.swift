//
//  FileManagerPreferences.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Пакет предпочитаемых настроек для работы с файловым менеджером
struct FileManagerPreferences {
    var preferredTextExtension: TextExtension
    var preferredImageExtension: ImageExtension
    var preferredDirectory: FMDirectory
    
    init(textExtension: TextExtension,
         imageExtension: ImageExtension,
         directory: FMDirectory) {
        self.preferredTextExtension = textExtension
        self.preferredImageExtension = imageExtension
        self.preferredDirectory = directory
    }
}
