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
    
    enum NotificationState { case showSucces(InAppNotificationViewModel),
                                  showError(InAppNotificationViewModel) }
    
    // MARK: - Properties
    let router: MainRouterProtocol
    let title = "Conversations"
    let conversations: Dynamic<[GroupedConversations]?> = Dynamic(nil)
    var onDataUpdate: (() -> Void)?
    var notificationCallback: Dynamic<NotificationState?> = Dynamic(nil)
    var profileAvatarUpdateInfo: Dynamic<ProfileAvatarUpdateInfo?> = Dynamic(nil)
    
    let repository: ConversationsRepositoryProtocol
    
    // MARK: - Initializer
    init(router: MainRouterProtocol,
         repository: ConversationsRepositoryProtocol? = nil) {
        self.router = router
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
    
    func didRequestRefresh(completion: @escaping () -> Void) {
        repository.updateConversationsOnce {
            completion()
        }
    }
    
    func newConversationButtonPressed(with name: String?) {
        repository.addConversation(with: name) { [weak self] result in
            self?.notifyViewWithUpdates(result)
        }
    }
    
    func isTextSendable(text: String?) -> Bool {
        if let text = text,
           text.isntEmptyOrWhitespaced() {
            return true
        } else {
            return false
        }
    }
    
    private func bindToRepositoryUpdates() {
        repository.model.bind(listener: { [weak self] conversations in
            self?.conversations
                .value = self?.mapConversationsByActivity(conversations)
            self?.onDataUpdate?()
        })
    }
    
    // Группируем модель по полю активности, структуру используем для отрисовки таблицы
    private func mapConversationsByActivity(
        _ conversations: [Conversation]
    ) -> [GroupedConversations] {
        return Dictionary(grouping: conversations) { $0.isActive }
        .map { (element) -> GroupedConversations in
            let sortedConversations = element.value.sorted {
                $0.lastActivity ?? .distantPast > $1.lastActivity ?? .distantPast
            }
            if element.key {
                return GroupedConversations(title: "Currently Active",
                                            conversations: sortedConversations,
                                            indexInTable: 0)
            } else {
                return GroupedConversations(title: "Inactive",
                                            conversations: sortedConversations,
                                            indexInTable: 1)
            }
        }
        .sorted { (lhs, rhs) -> Bool in
            switch (lhs.indexInTable, rhs.indexInTable) {
            case let(l?, r?): return l < r
            case (nil, _): return false
            case (_?, nil): return true
            }
        }
    }
    
    private func notifyViewWithUpdates(_ result: Result<String, Error>) {
        switch result {
        case .success(let message):
            let notificationModel = InAppNotificationViewModel(
                notificationType: .success,
                text: message)
            DispatchQueue.main.async {
                self.notificationCallback.value = .showSucces(notificationModel)
            }
        case .failure(let error):
            let notificationModel = InAppNotificationViewModel(
                notificationType: .error,
                text: error.localizedDescription)
            DispatchQueue.main.async {
                self.notificationCallback.value = .showError(notificationModel)
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

// MARK: - ProfileDelegate
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
        repository.fetchAvatarOrName { [weak self] result in
            switch result {
            case .success(let info):
                self?.profileAvatarUpdateInfo.value = info
            case .failure(let error):
                Log.error("Не удалось загрузить аватар или имя \(error.localizedDescription)")
            }
        }
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
        let conversation = getConversation(for: indexPath)
        return ConversationCellViewModel(with: conversation)
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let conversation = getConversation(for: indexPath)
        guard let conversationID = conversation?.identifier else {
            Log.error("Conversation ID = nil, невозможно совершить переход")
            return
        }
        let dmViewModel = DMViewModel(router: router,
                                      dialogueID: conversationID,
                                      chatName: conversation?.name)
        router.showDMViewController(animated: true, withViewModel: dmViewModel)
    }
    
    func didSwipeToDelete(at indexPath: IndexPath) {
        let conversation = getConversation(for: indexPath)
        repository.deleteConversation(
            withID: conversation?.identifier
        ) { [weak self] result in
            self?.notifyViewWithUpdates(result)
        }
    }
    
    private func getConversation(for indexPath: IndexPath) -> Conversation? {
        let conversationSection = conversations.value?[indexPath.section]
        return conversationSection?[indexPath.row]
    }
}

// MARK: - UISearchResultsUpdating
extension ConversationsViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
}
