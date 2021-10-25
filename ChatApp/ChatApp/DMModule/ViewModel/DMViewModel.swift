//
//  DMViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

/// Вью-модель экрана чата с собеседником
final class DMViewModel: Routable {
    
    let router: MainRouterProtocol
    let dialogueID: String
    let chatName: Dynamic<String?> = Dynamic(nil)
    let chatImage: Dynamic<UIImage?> = Dynamic(nil)
    
    var groupedMessages: [GroupedMessages]?
    
    init(router: MainRouterProtocol,
         dialogueID: String,
         chatName: String? = nil,
         chatImage: UIImage? = nil) {
        self.router = router
        self.dialogueID = dialogueID
        self.chatName.value = chatName
        self.chatImage.value = chatImage
        
        groupedMessages = makeGroupedMessages(40)
    }
    
    func sendMessagePressed() {
        Log.info("Send Message Pressed")
    }
    
    func addButtonPressed() {
        Log.info("Add Message Pressed")
    }
}

// MARK: - TableView Methods
extension DMViewModel {
    func numberOfSections() -> Int {
        return groupedMessages?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        let section = groupedMessages?[section]
        return section?.messages.count ?? 0
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        let date = groupedMessages?[section].groupName
        // Тут так же форматируем дату, если надо
        return date
    }
    
    func messageCellViewModel(forIndexPath indexPath: IndexPath) -> MessageCellViewModel? {
        let message = groupedMessages?[indexPath.section].messages[indexPath.row]
        return MessageCellViewModel(with: message)
    }
}

// MARK: - Data Mock
extension DMViewModel {
    
    func randomText(_ amountOfCharacters: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...Int.random(in: 0...amountOfCharacters))
                        .map { _ in letters.randomElement()! })
    }
    
    func generateRandomMessage() -> Message {
        let randomText: [String?] = [randomText(180), nil]
        let randomTime: [String?] = ["11:53", "12:40", "10:00", "5:30", nil]
        let randomDate: [String?] = ["Fri, Jul 26", "Sat, Jan 12", "Today", nil]
        return Message(text: randomText.randomElement() as? String,
                       time: randomTime.randomElement() as? String,
                       date: randomDate.randomElement() as? String,
                       sender: MessageSender.allCases.randomElement())
    }
    
    func makeGroupedMessages(_ amount: Int) -> [GroupedMessages] {
        var messages = [Message]()
        // Генерируем amount рандомных сообщений
        for _ in 0...amount {
            messages.append(generateRandomMessage())
        }
        // Берем только те, где есть сообщение, дата и время
        messages = messages.filter { $0.date != nil && $0.text != nil }
        // Группируем это все в словарик, где ключи это дата
        return Dictionary(grouping: messages, by: { $0.date! })
        // Мапим значения в структуру, чтобы легче было работать с таблицей
            .map {
                return GroupedMessages(groupName: $0.key, messages: $0.value)
            }
    }
}
