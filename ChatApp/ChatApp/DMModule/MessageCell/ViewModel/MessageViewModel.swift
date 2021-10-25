//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 06.10.2021.
//

import Foundation

/// Вью-модель ячейки сообщения
final class MessageCellViewModel {
    let text: Dynamic<String?> = Dynamic(nil)
    let time: Dynamic<String?> = Dynamic(nil)
    let isSender: Dynamic<Bool?> = Dynamic(nil)
    
    init(with message: Message? = nil) {
        updateValues(with: message)
    }
    
    private func updateValues(with message: Message?) {
        text.value = message?.text
        time.value = message?.time
        switch message?.sender {
        case .user:
            isSender.value = true
        case .friend:
            isSender.value = false
        case .none:
            isSender.value = nil
        }
    }
}
