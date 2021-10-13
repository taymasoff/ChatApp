//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

/// Вью-модель экрана диалогов
final class ConversationsViewModel: NSObject, Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    var title = "Tinkoff Chat"
    var conversations: [String : [Conversation]]?
    
    // MARK: - Initializer
    init(router: MainRouterProtocol) {
        self.router = router
        super.init()
        
        conversations = makeConversationsDictionary(40) // 👈 если нужно изменить количество моковых данных
    }
    
    // MARK: - Private Methods
    func profileBarButtonPressed() {
        router.presentProfileViewController()
    }
    
    func gearBarButtonPressed() {
        router.presentThemesViewController(onThemeChanged: logThemeChanging)
    }
    
    func logThemeChanging(_ color: UIColor) {
        Log.info("Получен выбранный пользователем цвет -> \(color.description)")
    }
}

// MARK: - TableView Methods
extension ConversationsViewModel {
    func numberOfSections() -> Int {
        return conversations?.keys.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let key = ConversationsSections.allCases[section].rawValue
        return conversations?[key]?.count ?? 0
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return ConversationsSections.allCases[section].rawValue.capitalized
    }
    
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModel? {
        let key = ConversationsSections.allCases[indexPath.section].rawValue
        let conversation = conversations?[key]?[indexPath.row]
        return ConversationCellViewModel(with: conversation)
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let key = ConversationsSections.allCases[indexPath.section].rawValue
        let conversation = conversations?[key]?[indexPath.row]
        let dmViewModel = DMViewModel(router: router,
                                      chatBuddyName: conversation?.userName,
                                      chatBuddyImageURL: conversation?.profileImageURL)
        router.showDMViewController(animated: true, withViewModel: dmViewModel)
    }
}

// MARK: - UISearchResultsUpdating
extension ConversationsViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
}

// MARK: - Data Mock
extension ConversationsViewModel {
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
                return ConversationsSections.online.rawValue
            } else {
                return ConversationsSections.history.rawValue
            }
        })
    }
}
