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
    private let cloudStore: FirestoreManager<Message>
    
    let messages: Dynamic<[Message]> = Dynamic([])
    
    init(with dialogueID: String,
         cloudStore: FirestoreManager<Message> = FirestoreManager(
            collectionName: FBCollections.channels.rawValue
         )) {
             let reference = cloudStore.db.collection(FBCollections.channels.rawValue).document(dialogueID).collection(FBCollections.messages.rawValue)
             cloudStore.reference = reference
             self.cloudStore = cloudStore
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
        bindCloudWithModel()
        cloudStore.subscribeToUpdates(enableLogging: true) { [weak self] result in
            switch result {
            case .success(let updateLog):
                self?.printUpdateLog(updateLog: updateLog)
                // Этим будет пользоваться CoreData для обновления БД
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
            case .success(let message):
                Log.info(message)
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
}
