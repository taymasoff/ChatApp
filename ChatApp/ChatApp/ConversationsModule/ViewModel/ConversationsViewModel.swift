//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

enum ProfileAvatarUpdateInfo { case avatar(UIImage), name(String) }

/// Вью-модель экрана диалогов
final class ConversationsViewModel: NSObject, Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    var title = "Tinkoff Chat"
    var conversations: [String: [Conversation]]?
    var profileAvatarUpdateInfo: Dynamic<ProfileAvatarUpdateInfo?> = Dynamic(nil)
    
    var persistenceManager: PersistenceManagerProtocol
    
    // MARK: - Initializer
    init(router: MainRouterProtocol,
         persistenceManager: PersistenceManagerProtocol? = nil) {
        self.router = router
        self.persistenceManager = persistenceManager ?? PersistenceManager()
        super.init()
        
        conversations = makeConversationsDictionary(40) // 👈 если нужно изменить количество моковых данных
    }
    
    // MARK: - Private Methods
    func profileBarButtonPressed() {
        router.presentProfileViewController(delegate: self)
    }
    
    func gearBarButtonPressed() {
        askToPickController()
    }
    
    private func askToPickController() {
        let alert = UIAlertController(title: "Выберите контроллер, который будет отвечать за презентацию модуля выбора темы", message: nil, preferredStyle: .actionSheet)
        
        let swiftOption = UIAlertAction(title: "Тот что на Swift",
                                         style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.router.presentThemesViewController(
                onThemeChanged: self.logThemeChanging
            )
        }
        
        let objcOption = UIAlertAction(title: "Тот что на Objective C",
                                          style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.router.presentThemesViewControllerObjc(
                delegate: self
            )
        }
        
        alert.addAction(swiftOption)
        alert.addAction(objcOption)
        
        router.presentAlert(alert, animated: true)
    }
    
    func logThemeChanging(_ color: UIColor) {
        Log.info("Получен выбранный пользователем цвет -> \(color.description)")
    }
}

// MARK: - PersistentManager Methods
extension ConversationsViewModel {
    // Ищем аватарку пользователя
    // если ее нет - возвращаем имя для генерации плейсхолдера
    // если и имя пустое - то ничего
    func fetchUserAvatarOrName() {
        persistenceManager.fetchImage(
            key: AppFileNames.userAvatar.rawValue
        ) { [weak self] result in
            if case .success(let image) = result {
                DispatchQueue.main.async {
                    self?.profileAvatarUpdateInfo.value = .avatar(image)
                }
            } else {
                self?.persistenceManager.fetchString(
                    key: AppFileNames.userName.rawValue
                ) { result in
                    if case .success(let name) = result {
                        DispatchQueue.main.async {
                            self?.profileAvatarUpdateInfo.value = .name(name)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.profileAvatarUpdateInfo.value = nil
                        }
                    }
                }
            }
        }
    }
}

extension ConversationsViewModel: ProfileDelegate {
    func didUpdateProfileAvatar(with info: ProfileAvatarUpdateInfo?) {
        profileAvatarUpdateInfo.value = info
    }
}

// MARK: - ThemesViewControllerDelegate
extension ConversationsViewModel: ThemesViewControllerDelegate {
    func themesViewController(_ controller: ThemesViewControllerObjc,
                              didSelectTheme selectedTheme: UIColor) {
        
        logThemeChanging(selectedTheme)
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
        return String((0...Int.random(in: 0...100)).map { _ in letters.randomElement()! })
    }
    
    func generateRandomConversation() -> Conversation {
        let userNames = ["Talisha Hakobyan", "Vitomir Mark",
                         "Maryna Madigan", "Margherita Simmon",
                         "Sudarshan Eckstein", "Berenice Ferreiro",
                         "Padma Traylor", "Isla Kumar", "Dareios Sternberg"]
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
    
    func makeConversationsDictionary(_ amount: Int) -> [String: [Conversation]] {
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
