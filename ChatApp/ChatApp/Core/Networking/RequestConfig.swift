//
//  RequestConfig.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

/// Конфигурация для RequestDispatcher'а
struct RequestConfig<Parser> where Parser: DataParserProtocol {
    
    /// Запрос, соответствующий протоколу RequestProtocol
    let request: RequestProtocol
    
    /// Парсер, соответствующий протоколу DataParserProtocol
    let parser: Parser
}
