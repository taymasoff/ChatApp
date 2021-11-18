//
//  ConversationsProvider.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.11.2021.
//

import UIKit

final class ConversationsProvider: NSObject {
    
    private let frcDataProvider: FRCDataProvider<DBChannel>
    
    var changes: Dynamic<[DataSourceChange]> {
        return frcDataProvider.changes
    }
    
    init(frcDataProvider: FRCDataProvider<DBChannel>) {
        self.frcDataProvider = frcDataProvider
        
        do {
            try frcDataProvider.startFetching()
        } catch {
            Log.error("Failed to fetch cached conversations: \(error)")
        }
    }
    
    func object(atIndexPath indexPath: IndexPath) -> Conversation {
        return frcDataProvider.entity(atIndexPath: indexPath).toDomainModel()
    }
}

// MARK: - UITableViewDataSource
extension ConversationsProvider: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return frcDataProvider.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frcDataProvider.numberOfObjectsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return frcDataProvider.nameOfSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: ConversationCell.reuseID,
                                 for: indexPath) as? ConversationCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти ConversationCell по идентификатору \(ConversationCell.reuseID). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        cell.configure(with: conversationCellViewModel(forIndexPath: indexPath))
        
        return cell
    }
    
    private func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModel {
        return ConversationCellViewModel(
            with: object(atIndexPath: indexPath)
        )
    }
}
