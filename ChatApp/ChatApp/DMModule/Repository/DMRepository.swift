//
//  DMRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

// MARK: - ConversationsRepositoryProtocol
protocol DMRepositoryProtocol {
    var messages: Dynamic<[Message]> { get }
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func newMessage(with content: String?)
}

final class DMRepository: DMRepositoryProtocol {
    
    // MARK: - Properties
    private var isFirstFetch = true
    private let dialogueID: String
    
    private let cloudStore: FirestoreManager<Message>
    private let cdContextProvider: CDContextProviderProtocol
    
    let messages: Dynamic<[Message]> = Dynamic([])
    
    init(with dialogueID: String,
         cloudStore: FirestoreManager<Message> = FirestoreManager(
            collectionName: FBCollections.channels.rawValue
         ),
         cdContextProvider: CDContextProviderProtocol = CDContextProvider.shared) {
        self.dialogueID = dialogueID
        let reference = cloudStore.db.collection(FBCollections.channels.rawValue).document(dialogueID).collection(FBCollections.messages.rawValue)
        cloudStore.reference = reference
        self.cloudStore = cloudStore
        self.cdContextProvider = cdContextProvider
    }
    
    private func bindCloudWithModel() {
        self.cloudStore.model.bind { [weak self] messages in
            self?.messages.value = messages
        }
    }
}

// MARK: - CloudStore Methods
extension DMRepository {
    
    // MARK: Print Update Log
    private func printUpdateLog(updateLog: CSModelUpdateLog<Message>?) {
        // Логирование не включено, или updateLog пустой
        guard let updateLog = updateLog else { return }
        print("🔥 [FirestoreUpdate]: Documents added: \(updateLog.addedCount) modified: \(updateLog.updatedCount) removed: \(updateLog.removedCount)")
    }
    
    // MARK: Subscribe to stream
    func subscribeToUpdates() {
        isFirstFetch = true
        bindCloudWithModel()
        cloudStore.subscribeToUpdates(enableLogging: true) { [weak self] result in
            switch result {
            case .success(let updateLog):
                self?.printUpdateLog(updateLog: updateLog)
                self?.updateCoreData(with: updateLog)
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: Unsubscribe
    func unsubscribeFromUpdates() {
        cloudStore.unsubscribeFromUpdates()
    }
    
    // MARK: Add Conversation
    func newMessage(with content: String?) {
        guard let content = content,
              content.isntEmptyOrWhitespaced else {
                  Log.error("Невозможно создать сообщение с пустым контентом.")
                  return
              }
        
        let message = Message(content: content)
        
        cloudStore.addEntity(from: message) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
}

// MARK: - Core Data Methods
extension DMRepository {
    
    // MARK: Save changes to Core Data
    private func updateCoreData(with updateLog: CSModelUpdateLog<Message>?) {
        guard let updateLog = updateLog else { return }
        
        let context = cdContextProvider.newBackgroundContext
        
        // Создаем воркера в бекграунд треде
        let saveWorker = CDWorker<Message, DBMessage>(
            context: context,
            mergePolicy: .mergeByPropertyObjectTrumpMergePolicyType
        )
        
        lazy var fetchWorker = CDWorker<Conversation, DBChannel>(
            context: context
        )
        lazy var conversationEntity = fetchWorker.coreDataManager
            .fetchEntity(withID: dialogueID)
        
        // Если мы только что подписались на изменения - чистим базу сообщений этого чата
        // и перезаписываем так как мы не можем знать какие изменения там произошли с прошлого запуска
        if isFirstFetch {
            let chatRelPredicate = NSPredicate(format: "channel.identifier == %@",
                                               dialogueID)
            saveWorker.coreDataManager.removeAll(matching: chatRelPredicate)
            isFirstFetch = false
        }
        
        if updateLog.addedCount != 0 {
            // Для каждого добавленного сообщения также меняем канал
            for object in updateLog.addedObjects {
                let entity = saveWorker.coreDataManager.insert(object)
                entity.channel = conversationEntity
            }
        }
        
        if updateLog.updatedCount != 0 {
            // При выбранной merge политике, insert должен работать как update
            for object in updateLog.updatedObjects {
                print(object)
                let entity = saveWorker.coreDataManager.insert(object)
                entity.channel = conversationEntity
            }
        }
        
        if updateLog.removedCount != 0 {
            // У сообщений нет уникального идентификатора, но дата вроде-как
            // достаточно уникальна, поэтому удаляем по ней)
            for object in updateLog.removedObjects {
                let predicate = NSPredicate(format: "created == %@",
                                            object.created as NSDate)
                saveWorker.coreDataManager.removeAll(matching: predicate)
            }
        }
        
        saveWorker.saveIfNeeded()
    }
}
