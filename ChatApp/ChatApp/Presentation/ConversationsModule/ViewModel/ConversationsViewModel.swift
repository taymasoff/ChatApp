//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель экрана диалогов
final class ConversationsViewModel: NSObject, Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    let title = "Conversations"
    var notificationCallback: Dynamic<NotificationState?> = Dynamic(nil)
    var profileAvatarUpdateInfo: Dynamic<ProfileAvatarUpdateInfo?> = Dynamic(nil)
    
    private let repository: ConversationsRepositoryProtocol
    private let conversationsProvider: ConversationsProvider
    
    var conversationsTableViewDataSource: UITableViewDataSource {
        return conversationsProvider
    }
    
    var tableViewChanges: Dynamic<[DataSourceChange]> {
        return conversationsProvider.changes
    }
    
    // MARK: - Initializer
    init(router: MainRouterProtocol,
         repository: ConversationsRepositoryProtocol? = nil,
         conversationsProvider: ConversationsProvider) {
        self.router = router
        self.repository = repository ?? ConversationsRepository()
        self.conversationsProvider = conversationsProvider
    }
    
    // MARK: - Private Methods
    func profileBarButtonPressed() {
        router.presentProfileViewController(delegate: self)
    }
    
    func gearBarButtonPressed() {
        askToPickController()
    }
    
    func didRequestRefresh(completion: @escaping (Bool) -> Void) {
        repository.updateConversationsOnce { isSuccessful in
            completion(isSuccessful)
        }
    }
    
    func newConversationButtonPressed(with name: String?) {
        repository.addConversation(with: name) { [weak self] result in
            self?.notifyViewWithUpdates(result)
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
        repository.fetchAvatarOrName { [weak self] result in
            switch result {
            case .success(let info):
                self?.profileAvatarUpdateInfo.value = info
            case .failure:
                break // Нет ни имени, ни аватарки
            }
        }
    }
    
    func viewWillAppear() {
        repository.subscribeToUpdates()
    }
    
    func viewWillDisappear() {
        repository.unsubscribeFromUpdates()
    }
}

// MARK: - UITableViewDelegate
extension ConversationsViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [unowned self] _, _, complete in
            self.didSwipeToDelete(at: indexPath) { _ in
                complete(true)
            }
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let conversation = conversationsProvider.object(atIndexPath: indexPath)
        guard let conversationID = conversation.identifier else {
            Log.error("Conversation ID = nil, невозможно совершить переход")
            return
        }
        router.showDMViewController(animated: true,
                                    dialogueID: conversationID,
                                    chatName: conversation.name,
                                    chatImage: nil)
    }

    func didSwipeToDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let conversation = conversationsProvider.object(atIndexPath: indexPath)
        repository.deleteConversation(
            withID: conversation.identifier
        ) { [weak self] result in
            self?.notifyViewWithUpdates(result)
            completion(true)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ConversationsViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        Log.info("Update search results not implemented yet")
    }
}
