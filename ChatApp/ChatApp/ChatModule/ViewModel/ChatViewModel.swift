//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation

enum ChatSections: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

protocol ChatViewModelProtocol {
    var router: MainRouterProtocol? { get }
    init(router: MainRouterProtocol)
    
    func profileBarButtonPressed()
    func gearBarButtonPressed()
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func conversation(forIndexPath indexPath: IndexPath) -> ConversationViewDataType?
}

final class ChatViewModel: ChatViewModelProtocol {
    
    var router: MainRouterProtocol?
    
    var conversations: [String : [Conversation]]?
    
    init(router: MainRouterProtocol) {
        self.router = router
        
        conversations = makeConversationsDictionary()
    }
    
    func profileBarButtonPressed() {
        router?.presentProfileViewController()
    }
    
    func gearBarButtonPressed() {
        // Обработка нажатия на левый BarButton
    }
}

// MARK: - TableView Delegate & Data Source Methods
extension ChatViewModel {
    func numberOfRowsInSection(_ section: Int) -> Int {
        let key = ChatSections.allCases[section].rawValue
        return conversations?[key]?.count ?? 0
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
    func makeConversationsDictionary() -> [String : [Conversation]] {
        let conversations: [Conversation] = [
            Conversation(profileImageURL: nil,
                         isOnline: true,
                         userName: "Ronald Robertson",
                         lastMessage: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                         messageDate: nil,
                         messageTime: nil,
                         hasUnreadMessages: true),
            Conversation(profileImageURL: nil,
                         isOnline: true,
                         userName: "Johnny Watson",
                         lastMessage: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis",
                         messageDate: nil,
                         messageTime: nil,
                         hasUnreadMessages: false),
            Conversation(profileImageURL: nil,
                         isOnline: false,
                         userName: "Martha Craig",
                         lastMessage: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
                         messageDate: nil,
                         messageTime: nil,
                         hasUnreadMessages: false)
        ]
        
        return Dictionary(grouping: conversations, by: {
            if $0.isOnline {
                return ChatSections.online.rawValue
            } else {
                return ChatSections.history.rawValue
            }
        })
    }
}
