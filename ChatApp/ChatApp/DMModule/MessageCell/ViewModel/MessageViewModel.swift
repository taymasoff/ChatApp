//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 06.10.2021.
//

import Foundation

protocol MessageCellViewModelProtocol {
    var text: Dynamic<String?> { get set }
    var time: Dynamic<String?> { get set }
    var isSender: Dynamic<Bool?> { get set }
    
    init(with message: Message?)
}

final class MessageCellViewModel: MessageCellViewModelProtocol {
    var text: Dynamic<String?> = Dynamic(nil)
    var time: Dynamic<String?> = Dynamic(nil)
    var isSender: Dynamic<Bool?> = Dynamic(nil)
    
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
