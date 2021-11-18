//
//  DMRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import CoreData

final class DMRepository: DMRepositoryProtocol {
    
    // MARK: - Properties
    private let dialogueID: String
    
    private let cloudStore: FirestoreManager<Message>
    private let coreDataStack: CoreDataStackProtocol
    
    private lazy var bgContext = coreDataStack.newBackgroundContext
    
    private lazy var bgWorker = CDWorker<Message, DBMessage>(
        context: bgContext,
        mergePolicy: .mergeByPropertyObjectTrumpMergePolicyType
    )
    
    private lazy var conversationEntity: DBChannel = {
        let conversationFetchWorker = CDWorker<Conversation, DBChannel>(
            context: bgContext
        )
        let predicate = NSPredicate(format: "identifier == %@", dialogueID)
        guard let chatEntity = try? conversationFetchWorker.coreDataManager
                .fetchFirstEntity(matching: predicate) else {
                    // Он всегда должен быть на этом этапе
                    fatalError("Не удалось получить объект текущего канала из кор даты")
                }
        return chatEntity
    }()
    
    // MARK: - Init
    init(dialogueID: String,
         cloudStore: FirestoreManager<Message> = FirestoreManager(
            collectionName: FBCollections.channels.rawValue
         ),
         coreDataStack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.dialogueID = dialogueID
        let reference = cloudStore.db.collection(FBCollections.channels.rawValue).document(dialogueID).collection(FBCollections.messages.rawValue)
        cloudStore.reference = reference
        self.cloudStore = cloudStore
        self.coreDataStack = coreDataStack
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
    
    /// Обновляет базу данных CoreData последними изменениями
    /// - Parameter updateLog: список изменений
    func updateCoreData(with updateLog: CSModelUpdateLog<Message>?) {
        guard let updateLog = updateLog else { return }
        
        if updateLog.addedCount != 0 {
            for object in updateLog.addedObjects {
                bgWorker.coreDataManager.insert(object) { [weak self] entity in
                    entity.channel = self?.conversationEntity
                }
            }
        }
        if updateLog.updatedCount != 0 {
            bgWorker.coreDataManager.update(
                updateLog.updatedObjects,
                updateBlock: { [weak self] object, entity in
                    object.insertInto(entity: entity)
                    entity.channel = self?.conversationEntity
                    return entity
                },
                insertIfNotExists: true,
                completion: { _ in }
            )
        }
        if updateLog.removedCount != 0 {
            for object in updateLog.removedObjects {
                let predicate = NSPredicate(format: "created == %@",
                                            object.created as NSDate)
                bgWorker.coreDataManager.removeAll(matching: predicate) { _ in }
            }
        }
        bgWorker.saveIfNeeded { _ in }
    }
}
