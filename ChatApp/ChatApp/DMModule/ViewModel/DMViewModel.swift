//
//  DMViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import CoreData

/// Вью-модель экрана чата с собеседником
final class DMViewModel: Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    let repository: DMRepositoryProtocol
    
    let chatName: Dynamic<String?> = Dynamic(nil)
    let chatImage: Dynamic<UIImage?> = Dynamic(nil)
    
    private let dialogueID: String
    
    let messagesProvider: MessagesProvider
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         dialogueID: String,
         chatName: String? = nil,
         chatImage: UIImage? = nil,
         repository: DMRepositoryProtocol? = nil,
         messagesProvider: MessagesProvider? = nil) {
        self.router = router
        self.dialogueID = dialogueID
        self.repository = repository ?? DMRepository(with: dialogueID)
        self.chatName.value = chatName
        self.chatImage.value = chatImage
        self.messagesProvider = messagesProvider ?? createProvider()
        
        func createProvider() -> MessagesProvider {
            let request = DBMessage.fetchRequest()
            let predicate = NSPredicate(format: "channel.identifier == %@", dialogueID)
            let sortByDateCreatedDescriptor = NSSortDescriptor(keyPath: \DBMessage.created,
                                                               ascending: true)
            request.predicate = predicate
            request.sortDescriptors = [sortByDateCreatedDescriptor]
            request.fetchBatchSize = 10
            let frc = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: CoreDataStack.shared.mainContext,
                sectionNameKeyPath: #keyPath(DBMessage.sectionName),
                cacheName: "MessagesCache"
            )
            return MessagesProvider(fetchedResultsController: frc)
        }
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
