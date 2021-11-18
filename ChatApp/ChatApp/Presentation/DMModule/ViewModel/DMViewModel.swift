//
//  DMViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель экрана чата с собеседником
final class DMViewModel: NSObject, Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    
    let chatName: Dynamic<String?> = Dynamic(nil)
    let chatImage: Dynamic<UIImage?> = Dynamic(nil)
    private let dialogueID: String
    
    private let repository: DMRepositoryProtocol
    private let messagesProvider: MessagesProvider
    
    var dmTableViewDataSource: UITableViewDataSource {
        return messagesProvider
    }
    
    var dmTableViewChanges: Dynamic<[DataSourceChange]> {
        return messagesProvider.changes
    }
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         dialogueID: String,
         chatName: String? = nil,
         chatImage: UIImage? = nil,
         repository: DMRepositoryProtocol? = nil,
         messagesProvider: MessagesProvider) {
        self.router = router
        self.dialogueID = dialogueID
        self.repository = repository ?? DMRepository(dialogueID: dialogueID)
        self.chatName.value = chatName
        self.chatImage.value = chatImage
        self.messagesProvider = messagesProvider
    }
    
    // MARK: - Action Methods
    func sendMessagePressed(with text: String?) {
        repository.newMessage(with: text)
    }
    
    func addButtonPressed() {
        Log.info("Add Message Pressed")
    }
    
    func isTextSendable(text: String?) -> Bool {
        if let text = text,
           text.isntEmptyOrWhitespaced {
            return true
        } else {
            return false
        }
    }
}

// MARK: - DMViewController Lifecycle Updates
extension DMViewModel {
    func viewDidLoad() {
        repository.subscribeToUpdates()
    }
}

// MARK: - UITableViewDelegate
extension DMViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
    }
}
