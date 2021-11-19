//
//  ConversationModuleAssembly.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import Foundation

/// Сборщик компонентов модуля каналов
class ConversationsModuleAssembler {
    
    struct Configuration {
        let fmPreferences: FileManagerPreferences
    }
    
    private let configuration: Configuration
    let container: DIContainer
    
    init(container: DIContainer,
         configuration: ConversationsModuleAssembler.Configuration) {
        self.container = container
        self.configuration = configuration
    }
    
    func assembleAll() {
        assembleConversationsProvider()
        assembleCoreDataStack()
        assembleFirestore()
        assembleRepository()
        assembleViewModel()
        assembleViewController()
    }
    
    func assembleViewController() {
        container.register(type: ConversationsViewController.self) { container in
            return ConversationsViewController(
                with: container.resolve(type: ConversationsViewModel.self)
            )
        }
    }
    
    func assembleViewModel() {
        container.register(type: ConversationsViewModel.self) { container in
            return ConversationsViewModel(
                router: container.resolve(type: MainRouter.self, asSingleton: true),
                repository: container.resolve(type: ConversationsRepository.self),
                conversationsProvider: container.resolve(type: ConversationsProvider.self)
            )
        }
    }
    
    func assembleRepository() {
        container.register(type: ConversationsRepository.self) { container in
            return ConversationsRepository(
                fileManager: container.resolve(type: GCDFileManager.self),
                fmPreferences: self.configuration.fmPreferences,
                cloudStore: container.resolve(type: FirestoreManager.self),
                coreDataStack: container.resolve(type: CoreDataStack.self,
                                                 asSingleton: true)
            )
        }
    }
    
    func assembleFirestore() {
        container.register(type: FirestoreManager<Conversation>.self) { _ in
            return FirestoreManager<Conversation>(
                collectionName: FBCollections.channels.rawValue
            )
        }
    }
    
    func assembleConversationsProvider() {
        container.register(type: ConversationsProvider.self) { _ in
            let request = DBChannel.fetchRequest()
            let sortByActivityDescriptor = NSSortDescriptor(
                keyPath: \DBChannel.lastActivity,
                ascending: false
            )
            request.sortDescriptors = [sortByActivityDescriptor]
            request.fetchBatchSize = 10
            return ConversationsProvider(
                fetchRequest: request,
                coreDataStack: CoreDataStack.shared,
                sectionKeyPath: #keyPath(DBChannel.sectionName),
                cacheName: "ConversationsCache"
            )
        }
    }
    
    func assembleCoreDataStack() {
        container.register(type: CoreDataStack.self) { _ in
            return CoreDataStack.shared
        }
    }
}
