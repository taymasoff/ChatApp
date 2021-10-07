//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

enum ConversationsSections: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

protocol ConversationsTableViewCompatible {
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func titleForHeaderInSection(_ section: Int) -> String?
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelProtocol?
    func didSelectRowAt(_ indexPath: IndexPath)
}

protocol ConversationsModelPresentable {
    var router: MainRouterProtocol? { get }
    var title: String { get }
    init(router: MainRouterProtocol)
    
    func profileBarButtonPressed()
    func gearBarButtonPressed()
}

final class ConversationsViewModel: NSObject, ConversationsModelPresentable {
    
    var router: MainRouterProtocol?
    var title = "Tinkoff Chat"
    var conversations: [String : [Conversation]]?
    
    init(router: MainRouterProtocol) {
        super.init()
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

// MARK: - ConversationsTableViewCompatible Methods
extension ConversationsViewModel: ConversationsTableViewCompatible {
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
    
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelProtocol? {
        let key = ConversationsSections.allCases[indexPath.section].rawValue
        let conversation = conversations?[key]?[indexPath.row]
        return ConversationCellViewModel(with: conversation)
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let key = ConversationsSections.allCases[indexPath.section].rawValue
        let conversation = conversations?[key]?[indexPath.row]
        let dmViewModel = DMViewModel(router: router!,
                                      chatBuddyName: conversation?.userName,
                                      chatBuddyImageURL: conversation?.profileImageURL)
        router?.showDMViewController(animated: true, withViewModel: dmViewModel)
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
