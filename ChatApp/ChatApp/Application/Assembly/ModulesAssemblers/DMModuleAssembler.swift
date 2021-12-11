//
//  DMModuleAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import Foundation

/// Сборщик компонентов модуля чата
class DMModuleAssembler {
    
    struct Configuration {
        let dialogueID: String
        let chatName: String?
        let chatImage: UIImage?
    }
    
    private let configuration: Configuration
    let container: DIContainer
    
    init(container: DIContainer,
         configuration: DMModuleAssembler.Configuration) {
        self.container = container
        self.configuration = configuration
    }
    
    func assembleAll() {
        assembleMessagesProvider()
        assembleFirestore()
        assembleRepository()
        assembleViewModel()
        assembleViewController()
    }
    
    func assembleViewController() {
        container.register(type: DMViewController.self) { container in
            return DMViewController(
                with: container.resolve(type: DMViewModel.self)
            )
        }
    }
    
    func assembleViewModel() {
        container.register(type: DMViewModel.self) { container in
            return DMViewModel(
                router: container.resolve(type: MainRouter.self, asSingleton: true),
                dialogueID: self.configuration.dialogueID,
                chatName: self.configuration.chatName,
                chatImage: self.configuration.chatImage,
                repository: container.resolve(type: DMRepository.self),
                messagesProvider: container.resolve(type: MessagesProvider.self)
            )
        }
    }
    // messages provider,
    func assembleRepository() {
        container.register(type: DMRepository.self) { container in
            return DMRepository(
                dialogueID: self.configuration.dialogueID,
                cloudStore: container.resolve(type: FirestoreManager<Message>.self),
                coreDataStack: container.resolve(type: CoreDataStack.self,
                                                 asSingleton: true)
            )
        }
    }
    
    func assembleFirestore() {
        container.register(type: FirestoreManager<Message>.self) { _ in
            return FirestoreManager<Message>(
                collectionName: FBCollections.channels.rawValue
            )
        }
    }
    
    func assembleMessagesProvider() {
        container.register(type: MessagesProvider.self) { container in
            let request = DBMessage.fetchRequest()
            let predicate = NSPredicate(format: "channel.identifier == %@",
                                        self.configuration.dialogueID)
            let sortByDateCreatedDescriptor = NSSortDescriptor(keyPath: \DBMessage.created,
                                                               ascending: true)
            request.predicate = predicate
            request.sortDescriptors = [sortByDateCreatedDescriptor]
            request.fetchBatchSize = 10
            
            return MessagesProvider(
                fetchRequest: request,
                coreDataStack: container.resolve(type: CoreDataStack.self,
                                                 asSingleton: true),
                sectionKeyPath: #keyPath(DBMessage.sectionName),
                cacheName: "MessagesCache"
            )
        }
    }
}
