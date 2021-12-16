//
//  RequestDispatcherProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/// Протокол диспетчера запросов
protocol RequestDispatcherProtocol: ResponseHandling {
    
    /// Инициализатор, требующий URL сессию
    init(urlSession: URLSession)
    
    /// Исполнить запрос
    /// - Parameter config: конфигурация запроса состоящая из реквеста и парсера результата
    /// - Parameter completion: комплишн хендлер, захватывающий объект модели результата в качестве параметра
    /// - Returns: опциональный URLSessionTask
    @discardableResult
    func executeRequest<Parser>(
        from config: RequestConfig<Parser>,
        completion: @escaping (Result<Parser.ModelType, NetworkError>) -> Void
    ) -> URLSessionTask?
}

/// Класс, который отвечает за диспетчеризацию запросов в заданной сессии
class RequestDispatcher: RequestDispatcherProtocol {
    
    /// URL сессия
    private var session: URLSession
    
    /// Инициализатор, требующий URL сессию
    required init(urlSession: URLSession = URLSession.shared) {
        self.session = urlSession
    }
    
    /// Исполнить запрос
    /// - Parameter config: конфигурация запроса состоящая из реквеста и парсера результата
    /// - Parameter completion: комплишн хендлер, захватывающий объект модели результата в качестве параметра
    /// - Returns: опциональный URLSessionTask
    @discardableResult
    func executeRequest<Parser>(
        from config: RequestConfig<Parser>,
        completion: @escaping (Result<Parser.ModelType, NetworkError>) -> Void
    ) -> URLSessionTask? {
        
        // Пытаемся сбилдить URLRequest в do-catch блоке и ловим ошибки, которые кидает метод buildURLRequest
        do {
            let request = try config.request.buildURLRequest()
            
            // Создаем дата таску с полученным реквестом
            let dataTask = session.dataTask(
                with: request
            ) { [weak self] data, urlResponse, error in
                // Хендлим полученные результаты на ошибки, проверяем статус коды и т.д.
                if let result = self?.handleURLResponse(data, urlResponse, error) {
                    // Чекаем результат
                    switch result {
                    case .success(let data):
                        // Если получена Data - отправляем ее к парсеру и хендлим результат
                        if let model = config.parser.parse(data: data) {
                            completion(.success(model))
                        } else {
                            completion(.failure(.parsingError(nil)))
                        }
                    case .failure(let error):
                        // Если пришла ошибка отправляем ее в комплишн
                        completion(
                            .failure(error)
                        )
                    }
                }
            }
            // Запускаем таску и возвращаем ее
            dataTask.resume()
            return dataTask
        } catch {
            completion(
                .failure(error as? NetworkError ?? NetworkError.badInput(nil))
            )
            return nil
        }
    }
}
