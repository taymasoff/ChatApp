//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

enum ChatSections: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

protocol ChatTableViewCompatible {
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func titleForHeaderInSection(_ section: Int) -> String?
    func conversation(forIndexPath indexPath: IndexPath) -> ConversationViewDataType?
}

protocol ChatViewModelPresentable {
    var router: MainRouterProtocol? { get }
    var title: String { get }
    init(router: MainRouterProtocol)
    
    func profileBarButtonPressed()
    func gearBarButtonPressed()
}

typealias ChatViewModelProtocol = ChatViewModelPresentable & ChatTableViewCompatible

final class ChatViewModel: ChatViewModelPresentable {
    
    var router: MainRouterProtocol?
    var title = "Tinkoff Chat"
    var conversations: [String : [Conversation]]?
    
    init(router: MainRouterProtocol) {
        self.router = router
        
        conversations = makeConversationsDictionary(40) // 👈 если нужно изменить количество моковых данных
    }
    
    func profileBarButtonPressed() {
        router?.presentProfileViewController()
    }
    
    func gearBarButtonPressed() {
        // Обработка нажатия на левый BarButton
    }
}

// MARK: - ChatTableViewCompatible Methods
extension ChatViewModel: ChatTableViewCompatible {
    func numberOfSections() -> Int {
        return conversations?.keys.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let key = ChatSections.allCases[section].rawValue
        return conversations?[key]?.count ?? 0
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return ChatSections.allCases[section].rawValue.capitalized
    }
    
    func conversation(forIndexPath indexPath: IndexPath) -> ConversationViewDataType? {
        let key = ChatSections.allCases[indexPath.section].rawValue
        guard let conversation = conversations?[key]?[indexPath.row] else {
            Log.error("No conversation for indexPath: \(indexPath)")
            return nil
        }
        return ConversationViewData(conversation: conversation)
    }
}

// MARK: - Data Mock
extension ChatViewModel {
    func randomText() -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...Int.random(in: 0...100)).map{ _ in letters.randomElement()! })
    }
    
    func generateRandomConversation() -> Conversation {
        let userNames = ["Talisha Hakobyan", "Vitomir Mark", "Maryna Madigan", "Margherita Simmon", "Sudarshan Eckstein", "Berenice Ferreiro", "Padma Traylor", "Isla Kumar", "Dareios Sternberg"]
        let randomText: [String?] = [randomText(), nil]
        return Conversation(
            profileImageURL: nil,
            isOnline: Bool.random(),
            userName: userNames.randomElement(),
            lastMessage: randomText.randomElement() as? String,
            messageDate: nil,
            messageTime: nil,
            hasUnreadMessages: ([true, false].randomElement() != nil))
    }
    
    func makeConversationsDictionary(_ amount: Int) -> [String : [Conversation]] {
        var conversations: [Conversation] {
            var conversations = [Conversation]()
            for _ in 0...amount {
                conversations.append(generateRandomConversation())
            }
            return conversations
        }
        
        return Dictionary(grouping: conversations, by: {
            if $0.isOnline {
                return ChatSections.online.rawValue
            } else {
                return ChatSections.history.rawValue
            }
        })
    }
}
