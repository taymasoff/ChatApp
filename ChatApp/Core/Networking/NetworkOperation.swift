//
//  NetworkOperationProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/// Протокол, которому должны следовать все Network операции
protocol NetworkOperationProtocol {
    associatedtype Parser: DataParserProtocol
    associatedtype Output
    
    /// Конфигурация запроса, которую следует исполнить
    var config: RequestConfig<Parser> { get }
    
    /// Метод исполнения запроса в заданном диспетчере
    func execute(in requestDispatcher: RequestDispatcherProtocol,
                 completion: @escaping (Output) -> Void)
    
    /// Метод отмены операции
    func cancel()
}

/// Класс Network операции, который может исполнить запрос и отменить его
class NetworkOperation<Parser: DataParserProtocol>: NetworkOperationProtocol {
    typealias Parser = Parser
    typealias Output = Result<Parser.ModelType, NetworkError>
    
    /// Ссылка на исполняемую задачу
    private var task: URLSessionTask?
    
    /// Конфигурация запроса
    var config: RequestConfig<Parser>
    
    /// Инициализатор операции
    init(config: RequestConfig<Parser>) {
        self.config = config
    }
    
    /// Исполняет запрос в диспетчере запросов и сохраняет полученную задачу
    /// - Parameters:
    ///   - requestDispatcher: диспетчер запросов
    ///   - completion: результат полученный из диспетчера
    func execute(in requestDispatcher: RequestDispatcherProtocol,
                 completion: @escaping (Output) -> Void) {
        task = requestDispatcher.executeRequest(from: config) { result in
            completion(result)
        }
    }
    
    /// Отменить сохраненную задачу
    func cancel() {
        task?.cancel()
    }
}
