//
//  ImageExtension.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

/// Список доступных текстовых расширений
enum TextExtension {
    case txt
    case json
    
    var fileExtension: String {
        switch self {
        case .txt:
            return ".txt"
        case .json:
            return ".json"
        }
    }
}

/// Список доступных расширений изображений
enum ImageExtension {
    case png
    case jpeg(CGFloat) // Compression quality
    
    var fileExtension: String {
        switch self {
        case .png:
            return ".png"
        case .jpeg:
            return ".jpeg"
        }
    }
}
