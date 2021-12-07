//
//  MessagesProvider.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.11.2021.
//

import UIKit

final class MessagesProvider: NSObject {
    
    private let frcDataProvider: FRCDataProvider<DBMessage>
    private let imageRetriever: ImageRetrieverProtocol
    
    var changes: Dynamic<[DataSourceChange]> {
        return frcDataProvider.changes
    }
    
    init(frcDataProvider: FRCDataProvider<DBMessage>,
         imageRetriever: ImageRetrieverProtocol) {
        self.frcDataProvider = frcDataProvider
        self.imageRetriever = imageRetriever
        
        do {
            try frcDataProvider.startFetching()
        } catch {
            Log.error("Failed to fetch cached messages: \(error)")
        }
    }
    
    func handleCellImageUpdate(fromText text: String?,
                               completion: @escaping (UIImage?, String?) -> Void) {
        guard let text = text else {
            DispatchQueue.main.async {
                completion(nil, nil)
            }
            return
        }
        imageRetriever.retrieveFirstImage(fromText: text) { image, text in
            DispatchQueue.main.async {
                completion(image, text)
            }
        }
    }
    
    func object(atIndexPath indexPath: IndexPath) -> Message {
        return frcDataProvider.entity(atIndexPath: indexPath).toDomainModel()
    }
}

// MARK: - TableViewDataSource Methods
extension MessagesProvider: UITableViewDataSource {

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
            .dequeueReusableCell(withIdentifier: MessageCell.reuseID,
                                 for: indexPath) as? MessageCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти MessageCell по идентификатору \(MessageCell.reuseID). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        cell.configure(with: messageCellViewModel(forIndexPath: indexPath))
        
        cell.updateCellImage { [weak self] textViewText, completion in
            self?.handleCellImageUpdate(fromText: textViewText, completion: completion)
        }
        
        return cell
    }
    
    private func messageCellViewModel(forIndexPath indexPath: IndexPath) -> MessageCellViewModel {
        return MessageCellViewModel(
            with: object(atIndexPath: indexPath)
        )
    }
}
