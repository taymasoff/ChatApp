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
    
    // MARK: - Properties
    let router: MainRouterProtocol
    let repository: DMRepositoryProtocol
    
    let chatName: Dynamic<String?> = Dynamic(nil)
    let chatImage: Dynamic<UIImage?> = Dynamic(nil)
    
    let messages: Dynamic<[GroupedMessages]?> = Dynamic(nil)
    var onDataUpdate: (() -> Void)?
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         dialogueID: String,
         chatName: String? = nil,
         chatImage: UIImage? = nil,
         repository: DMRepositoryProtocol? = nil) {
        self.router = router
        self.repository = repository ?? DMRepository(with: dialogueID)
        self.chatName.value = chatName
        self.chatImage.value = chatImage
    }
    
    // MARK: - Action Methods
    func sendMessagePressed(with text: String?) {
        repository.newMessage(with: text) { result in
            switch result {
            case .success(let message):
                Log.info(message)
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
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
    
    // MARK: - Bind to Repository Updates
    private func bindToRepositoryUpdates() {
        repository.messages.bind { [unowned self] messages in
            self.messages
                .value = self.mapMessagesByDate(messages)
            self.onDataUpdate?()
        }
    }
    
    // Группируем модель по полю активности, структуру используем для отрисовки таблицы
    private func mapMessagesByDate(
        _ messages: [Message]
    ) -> [GroupedMessages] {
        return Dictionary(grouping: messages) { $0.created.noTime() }
        .map { (element) -> GroupedMessages in
            let sortedMessages = element.value.sorted {
                $0.created < $1.created
            }
            return GroupedMessages(date: element.key,
                                   messages: sortedMessages)
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - DMViewController Lifecycle Updates
extension DMViewModel {
    func viewDidLoad() {
        bindToRepositoryUpdates()
        repository.subscribeToUpdates()
    }
}

// MARK: - TableView Methods
extension DMViewModel {
    func numberOfSections() -> Int {
        return messages.value?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return messages.value?[section].numberOfItems ?? 0
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        guard let section = messages.value?[section] else {
            Log.error("Не удалось получить секцию для хедера")
            return nil
        }
        return section.formattedDate
    }
    
    func messageCellViewModel(forIndexPath indexPath: IndexPath) -> MessageCellViewModel? {
        let message = getMessage(for: indexPath)
        return MessageCellViewModel(with: message)
    }
    
    private func getMessage(for indexPath: IndexPath) -> Message? {
        let messagesSection = messages.value?[indexPath.section]
        return messagesSection?[indexPath.row]
    }
}
