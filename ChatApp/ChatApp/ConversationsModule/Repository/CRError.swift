//
//  CRError.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import Foundation

/// ConversationsRepository Error
enum CRError: Error {
    case emptyString
    case documentAddError
}

extension CRError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyString:
            return NSLocalizedString("Одно или несколько из введенных полей пусты", comment: "Empty string")
        case .documentAddError:
            return NSLocalizedString("Произошла ошибка при добавлении документа", comment: "Document add error")
        }
    }
}
