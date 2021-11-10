//
//  MessagesProvider.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.11.2021.
//

import CoreData
import UIKit

final class MessagesProvider: NSObject, TableViewProviderProtocol {
    
    // MARK: - Properties
    private let frc: NSFetchedResultsController<DBMessage>
    
    private var changesCache: [DataSourceChange] = []
    let changes: Dynamic<[DataSourceChange]> = Dynamic([])
    
    // MARK: - Init
    init(fetchedResultsController: NSFetchedResultsController<DBMessage>) {
        self.frc = fetchedResultsController
        
        super.init()
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Couldn't perform Messages fetch. Error: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MessagesProvider: NSFetchedResultsControllerDelegate {
    
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
extension MessagesProvider: UITableViewDataSource {

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
            .dequeueReusableCell(withIdentifier: MessageCell.reuseID,
                                 for: indexPath) as? MessageCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти MessageCell по идентификатору \(MessageCell.reuseID). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        cell.configure(with: messageCellViewModel(forIndexPath: indexPath))
        
        return cell
    }
    
    private func messageCellViewModel(forIndexPath indexPath: IndexPath) -> MessageCellViewModel {
        let message = object(at: indexPath)
        return MessageCellViewModel(with: message)
    }
    
    func object(at indexPath: IndexPath) -> Message {
        return frc.object(at: indexPath).toDomainModel()
    }
}
