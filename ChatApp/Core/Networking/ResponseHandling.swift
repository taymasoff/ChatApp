//
//  ResponseHandling.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/// Вспомогательный протокол, который берет на себя хендлинг ответа с сервера и разбивает его на результирующий тип Data или NetworkError
protocol ResponseHandling {
    
    /// Обрабатывает результат запроса
    /// - Parameters:
    ///   - data: опциональная Data
    ///   - urlResponse: опциональный URLResponse
    ///   - error: опциональная ошибка
    /// - Returns: результат в виде неопциональной Data или NetworkError
    func handleURLResponse(_ data: Data?,
                           _ urlResponse: URLResponse?,
                           _ error: Error?) -> Result<Data, NetworkError>
}

// MARK: - ResponseHandling Default Implementation
extension ResponseHandling {
    func handleURLResponse(_ data: Data?,
                           _ urlResponse: URLResponse?,
                           _ error: Error?) -> Result<Data, NetworkError> {
        
        // Проверяем есть ли респонс, если нет - возвращаем ошибку
        guard let urlResponse = urlResponse as? HTTPURLResponse else {
            return .failure(.requestFailed(nil))
        }
        
        // Хэндлим статус коды, если успешные то возвращаем Data, остальные сортируем по ошибкам
        switch urlResponse.statusCode {
        // 200 - 300 ответ пришел и можно пробовать достать data
        case 200..<300:
            if let data = data {
                return .success(data)
            } else {
                return .failure(.noData)
            }
        // 400 - 500 сервер отверг ответ
        case 400..<500:
            return .failure(.requestFailed(error?.localizedDescription))
        // 500 - 600 ошибка на стороне сервера
        case 500..<600:
            return .failure(.serverError(error?.localizedDescription))
        // Неизвестная ошибка
        default:
            return .failure(.unknown(error?.localizedDescription))
        }
    }
}
