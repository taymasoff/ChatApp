//
//  ConversationsProvider.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.11.2021.
//

import CoreData
import UIKit

final class ConversationsProvider: NSObject, TableViewProviderProtocol {
    
    // MARK: - Properties
    private let frc: NSFetchedResultsController<DBChannel>
    
    private var changesCache: [DataSourceChange] = []
    let changes: Dynamic<[DataSourceChange]> = Dynamic([])
    
    // MARK: - Init
    init(fetchedResultsController: NSFetchedResultsController<DBChannel>) {
        self.frc = fetchedResultsController

        super.init()
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Couldn't perform Conversations fetch. Error: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ConversationsProvider: NSFetchedResultsControllerDelegate {
    
    // MARK: Will Change Content
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        changes.value.removeAll()
    }
    
    // MARK: Did Change Section Info
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        if type == .insert {
            changesCache.append(.section(.inserted(sectionIndex)))
        } else if type == .delete {
            changesCache.append(.section(.deleted(sectionIndex)))
        }
    }
    
    // MARK: Did Change Object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            changesCache.append(.object(.inserted(at: newIndexPath!)))
        case .delete:
            changesCache.append(.object(.deleted(from: indexPath!)))
        case .move:
            changesCache.append(.object(.moved(from: indexPath!, to: newIndexPath!)))
        case .update:
            changesCache.append(.object(.updated(at: indexPath!)))
        default:
            break
        }
    }
    
    // MARK: Did Change Content
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        changes.value.append(contentsOf: changesCache)
        changesCache.removeAll()
    }
}

// MARK: - TableViewDataSource Methods
extension ConversationsProvider: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = frc.sections, sections.endIndex > section else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return frc.sections?[section].name
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
        let conversation = object(at: indexPath)
        return ConversationCellViewModel(with: conversation)
    }
    
    func object(at indexPath: IndexPath) -> Conversation {
        return frc.object(at: indexPath).toDomainModel()
    }
}
