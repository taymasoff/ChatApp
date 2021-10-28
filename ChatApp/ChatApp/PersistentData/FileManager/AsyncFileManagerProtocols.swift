//
//  AsyncFileManagerProtocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import Foundation

// MARK: - Async File Manager Protocol
typealias AsyncFileManagerProtocol = FileManagerProtocol & FMAsyncReadable & FMAsyncWritable & FMAsyncQoSModifiable

// MARK: - File Manager Async QoS Modifiable

protocol FMAsyncQoSModifiable {
    
    /// Позволяет задать предпочитаемый приоритет сервиса для асинхронных задач файлового менеджера
    func setQoS(_ qos: QualityOfService)
}

// MARK: - File Manager Async Readable
protocol FMAsyncReadable {
    
    /// Создает операцию чтения файла в бекграунд потоке
    /// - Parameters:
    ///   - name: полное имя файла с расширением
    ///   - directory: директория хранения файла
    ///   - completion: результат в виде Data или ошибка
    func read(fromFileNamed name: String,
              at directory: FMDirectory,
              completion: @escaping CompletionHandler<Data>)
}

// MARK: - File Manager Async Writable
protocol FMAsyncWritable {
    
    /// Создает операцию записи файла в бекграунд потоке
    /// - Parameters:
    ///   - data: данные файла представленные в формате Data
    ///   - name: имя файла в который необходимо произвести запись или создать новый
    ///   - directory: директория в которой будет расположен файл
    ///   - completion: результат в виде Успех/Неудача или ошибка
    func write(data: Data,
               inFileNamed name: String,
               at directory: FMDirectory,
               completion: @escaping CompletionHandler<Bool>)
}
