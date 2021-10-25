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
    let title = "Conversations"
    let conversations: Dynamic<[GroupedConversations]?> = Dynamic(nil)
    var onUpdate: (() -> Void)?
    var profileAvatarUpdateInfo: Dynamic<ProfileAvatarUpdateInfo?> = Dynamic(nil)
    
    var persistenceManager: PersistenceManagerProtocol
    let repository: ConversationsRepositoryProtocol
    
    // MARK: - Initializer
    init(router: MainRouterProtocol,
         persistenceManager: PersistenceManagerProtocol? = nil,
         repository: ConversationsRepositoryProtocol? = nil) {
        self.router = router
        self.persistenceManager = persistenceManager ?? PersistenceManager()
        self.repository = repository ?? ConversationsRepository()
        super.init()
    }
    
    // MARK: - Private Methods
    func profileBarButtonPressed() {
        router.presentProfileViewController(delegate: self)
    }
    
    func gearBarButtonPressed() {
        askToPickController()
    }
    
    private func bindToRepositoryUpdates() {
        repository.conversations.bind(listener: { [weak self] conversations in
            self?.conversations
                .value = self?.mapConversationsByActivity(conversations)
            self?.onUpdate?()
        })
    }
    
    // Группируем модель по полю активности, структуру используем для отрисовки таблицы
    private func mapConversationsByActivity(
        _ conversations: [Conversation]
    ) -> [GroupedConversations] {
        return Dictionary(grouping: conversations) { $0.isActive }
        .map { (element) -> GroupedConversations in
            if element.key {
                return GroupedConversations(title: "Currently Active",
                                            conversations: element.value)
            } else {
                return GroupedConversations(title: "Inactive",
                                            conversations: element.value)
            }
        }
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

// MARK: - ConversationsViewController Lifecycle Updates
extension ConversationsViewModel {
    func viewDidLoad() {
        bindToRepositoryUpdates()
        repository.subscribeToUpdates()
    }
}

// MARK: - TableView Methods
extension ConversationsViewModel {
    func numberOfSections() -> Int {
        return conversations.value?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return conversations.value?[section].numberOfItems ?? 0
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return conversations.value?[section].title.capitalized
    }
    
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModel? {
        let conversationSection = conversations.value?[indexPath.section]
        let conversation = conversationSection?[indexPath.row]
        return ConversationCellViewModel(with: conversation)
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let conversationSection = conversations.value?[indexPath.section]
        let conversation = conversationSection?[indexPath.row]
        guard let conversationID = conversation?.identifier else {
            Log.error("Conversation ID = nil, невозможно совершить переход")
            return
        }
        let dmViewModel = DMViewModel(router: router,
                                      dialogueID: conversationID,
                                      chatName: conversation?.name)
        router.showDMViewController(animated: true, withViewModel: dmViewModel)
    }
}

// MARK: - UISearchResultsUpdating
extension ConversationsViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
}
