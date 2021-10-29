//
//  Log.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import Foundation

/*
 👉 Простой логер событий в консоль. В будущем можно легко дополнить и модифицировать.
 ⚙️ Использование: Log.info(...) или Log.error(...)
 🖥 Пример вывода:
    10:16:46537 📝 [AppDelegate.swift]: application(_:didFinishLaunchingWithOptions:) -> App just Launched
 */

fileprivate enum LoggerOutputType {
    case info
    case error
    
    var emoji: String {
        switch self {
        case .info:
            return "📝"
        case .error:
            return "‼️"
        }
    }
}

internal class Log {
    
    enum LoggerState {
        case enabled
        case disabled
        case onlyInDebug
        
        var isEnabled: Bool {
            switch self {
            case .enabled:
                return true
            case .disabled:
                return false
            case .onlyInDebug:
                #if DEBUG
                return true
                #else
                return false
                #endif
            }
        }
    }
    
    private init() {}
    
    /// Включен ли логер
    fileprivate static var isLoggingEnabled: Bool = LoggerState.onlyInDebug.isEnabled
    
    /// Выводит ли дату
    fileprivate static var includesDate: Bool = false
    
    /// Выводит ли имя файла
    fileprivate static var includesFileNames: Bool = false
    
    /// Выводит ли имя функции
    fileprivate static var includesFuncNames: Bool = false
    
    /// Формат представляемой даты
    static var dateFormat: String = "hh:mm:ssSSS"
    fileprivate static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    /// Настройка логера
    /// - Parameters:
    ///   - loggerState: состояние логирования
    ///   - includeDate: включать ли в вывод дату
    ///   - includeFileNames: включать ли в вывод имя файла
    ///   - includeFuncNames: включать ли в вывод имя функции
    class func setup(loggerState: LoggerState,
                     includeDate: Bool,
                     includeFileNames: Bool,
                     includeFuncNames: Bool) {
        Self.isLoggingEnabled = loggerState.isEnabled
        Self.includesDate = includeDate
        Self.includesFileNames = includeFileNames
        Self.includesFuncNames = includeFuncNames
    }
    
    /// Выводит форматированное информационное сообщение в консоль
    /// - Parameters:
    ///   - object: Объект логирования
    ///   - filename: Название файла, из которого ведется логирование
    ///   - funcName: Название функции, откуда вызван метод логирования
    class func info(_ object: Any,
                 fileName: String = #file,
                 funcName: String = #function) {
        
        guard isLoggingEnabled else { return }
        let prefix = createPrefix(fileName: fileName,
                                  funcName: funcName,
                                  loggerOutput: .info)
        print("\(prefix) \(object)")
    }
    
    /// Выводит форматированное сообщение об ошибке в консоль
    /// - Parameters:
    ///   - object: Объект логирования
    ///   - filename: Название файла, из которого ведется логирование
    ///   - funcName: Название функции, откуда вызван метод логирования
    class func error(_ object: Any,
                     fileName: String = #file,
                     funcName: String = #function) {
        guard isLoggingEnabled else { return }
        let prefix = createPrefix(fileName: fileName,
                                  funcName: funcName,
                                  loggerOutput: .error)
        print("\(prefix) \(object)")
    }
    
    /// Создает префикс для вывода сообщения
    /// - Parameters:
    ///   - fileName: Название файла, из которого ведется логирование
    ///   - funcName: Название функции, откуда вызван метод логирования
    ///   - loggerOutput: Тип вывода info/error
    /// - Returns: Отформатированную строку вывода
    fileprivate class func createPrefix(
        fileName: String,
        funcName: String,
        loggerOutput: LoggerOutputType
    ) -> String {
        let emojiComponent = loggerOutput.emoji
        let dateComponent = includesDate ? Date().toString() : nil
        let fileNameComponent = includesFileNames ?
        "[\(sourceFileName(filePath: fileName))]:" : nil
        let funcNameComponent = includesFuncNames ? "\(funcName) ->" : nil
        return [dateComponent, emojiComponent, fileNameComponent, funcNameComponent]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    /// Получает название файла из пути
    /// - Parameter filePath: Полный путь файла
    /// - Returns: Название файла с разрешением
    fileprivate class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

fileprivate extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

/// Persistence Manager Logger
internal class PMLog: Log {
    
    override class func setup(loggerState: Log.LoggerState,
                              includeDate: Bool,
                              includeFileNames: Bool = false,
                              includeFuncNames: Bool = false) {
        Self.isLoggingEnabled = loggerState.isEnabled
        Self.includesDate = includeDate
    }
    
    override fileprivate class func createPrefix(
        fileName: String,
        funcName: String,
        loggerOutput: LoggerOutputType) -> String {
            let emojiComponent = "📂"
            let dateComponent = includesDate ? Date().toString() : nil
            return [dateComponent, emojiComponent, "[FileManager]:"]
                .compactMap { $0 }
                .joined(separator: " ")
        }
    
}

