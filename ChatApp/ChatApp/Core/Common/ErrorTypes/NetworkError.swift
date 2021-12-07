//
//  NetworkError.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.11.2021.
//

import Foundation

enum NetworkError: Error {
    /// Не получилось создать Request или он не валиден
    case badInput(String?)
    /// Сервер не вернул никаких данных
    case noData
    /// Request отвергнут сервером (400-499)
    case requestFailed(String?)
    /// Ошибка на стороне сервера (500-599)
    case serverError(String?)
    /// Ошибка при парсинге данных
    case parsingError(String?)
    /// Неизвестная ошибка
    case unknown(String?)
}

// MARK: - Localized Descriptions
extension NetworkError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .badInput(let message):
            return NSLocalizedString(
                "📲 Не удалось собрать валидный запрос. "
                    .appending(message ?? ""),
                comment: "Bad Input"
            )
        case .noData:
            return NSLocalizedString(
                "📭 Сервер не вернул никаких данных.",
                comment: "No Data"
            )
        case .requestFailed(let message):
            return NSLocalizedString(
                "❌ Запрос отвергнут сервером. "
                    .appending(message ?? ""),
                comment: "Request Failed"
            )
        case .serverError(let message):
            return NSLocalizedString(
                "♨️ Произошла ошибка на стороне сервера. "
                    .appending(message ?? ""),
                comment: "Server Error"
            )
        case .parsingError(let message):
            return NSLocalizedString(
                "🪄 Не удалось преобразовать данные. "
                    .appending(message ?? ""),
                comment: "Parsing Error"
            )
        case .unknown(let message):
            return NSLocalizedString(
                "🤷‍♂️ Произошла неизвестная ошибка. "
                    .appending(message ?? ""),
                comment: "Unknown Error"
            )
        }
    }
}
