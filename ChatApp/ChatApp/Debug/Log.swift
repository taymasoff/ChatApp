//
//  Log.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import Foundation

/*
 👉 Простой логер событий в консоль. В будущем можно легко дополнить и модифицировать.
 ⚙️ Использование: Log.info(...)
 🖥 Пример вывода:
    10:16:46537 📝 [AppDelegate.swift]: application(_:didFinishLaunchingWithOptions:) -> App just Launched
 */

class Log {
    private static var isLoggingEnabled: Bool {
        // Можно добавить какую-нибудь другую логику.
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var dateFormat = "hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    /// Вывод информационного сообщения в консоль
    /// - Parameters:
    ///   - object: Объект логирования
    ///   - filename: Название файла, из которого ведется логирование
    ///   - funcName: Название функции, откуда вызван метод логирования
    class func info(_ object: Any,
                 filename: String = #file,
                 funcName: String = #function) {
        
         if isLoggingEnabled {
             print("\(Date().toString()) 📝 [\(sourceFileName(filePath: filename))]: \(funcName) -> \(object)")
         }
    }
    
    /// Получает название файла из пути
    /// - Parameter filePath: Полный путь файла
    /// - Returns: Название файла с разрешением
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
