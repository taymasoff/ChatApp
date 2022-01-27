//
//  Request.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.11.2021.
//

import Foundation

/// Протокол запроса, который также собирает этот запрос
protocol RequestProtocol {
    
    /// URL хоста
    var baseURL: String { get }
    
    /// Путь запроса
    var path: String { get }
    
    /// Метод запроса
    var method: HTTPMethod { get }
    
    /// Параметры запроса
    var parameters: RequestParameters? { get }
    
    /// Таймаут интервал запроса
    var timeoutInteval: TimeInterval? { get }
    
    /// Метод сборки параметров в URLRequest
    /// - Returns: URLRequest или ошибка (NetworkError)
    func buildURLRequest() throws -> URLRequest
}

/// Параметры запроса. Body - с телом запроса или url - внутри URL
enum RequestParameters {
    
    /// Параметры передаются в теле функции
    case body(_ : [String: Any]?)
    
    /// Параметры передаются вместе с URLом
    case url(_ : [String: Any]?)
}

/// HTTP методы
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Build Request Default Implementation
extension RequestProtocol {
    
    /// Собирает заданные параметры в URLRequest
    /// - Returns: URLRequest или ошибку (NetworkError)
    func buildURLRequest() throws -> URLRequest {
        
        // Создаем компоненты
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.baseURL
        urlComponents.path = self.path
        
        // Пробуем собрать URL
        guard let url = urlComponents.url else {
            throw NetworkError.badInput("Не удалось собрать URL из компонентов \(baseURL) и \(path)")
        }
        
        // Нам нужен запрос чтобы можно было добавить параметры в body
        var request = URLRequest(url: url)
        
        try addParameters(to: &request, urlComponents: &urlComponents)
        
        // Собираем окончательный URL
        request.url = urlComponents.url
        // Добавляем метод запроса
        request.httpMethod = self.method.rawValue
        // Если есть timeoutInterval задаем его
        if let timeoutInterval = self.timeoutInteval {
            request.timeoutInterval = timeoutInterval
        }
        
        return request
    }
    
    /// Добавляет параметры в тело запроса или к URL, в зависимости от выбранной опции
    /// - Parameters:
    ///   - request: ссылнка на URLRequest
    ///   - urlComponents: ссылка на URL компоненты
    private func addParameters(to request: inout URLRequest,
                               urlComponents: inout URLComponents) throws {
        switch self.parameters {
        case .body(let params):
            if let params = params as? [String: String] {
                request.httpBody = try? JSONSerialization.data(
                    withJSONObject: params,
                    options: .init(rawValue: 0)
                )
            } else {
                throw NetworkError.badInput("Не удалось собрать тело запроса из параметров: \(String(describing: params))")
            }
        case .url(let params):
            if let params = params as? [String: String] {
                let queryParameters = params.map { (element) -> URLQueryItem in
                    return URLQueryItem(name: element.key, value: element.value)
                }
                urlComponents.queryItems = queryParameters
            } else {
                throw NetworkError.badInput("Не удалось добавить параметры \(String(describing: params)) в URL запрос")
            }
        default:
            break
        }
    }
}
