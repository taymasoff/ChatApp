//
//  ConversationsRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.10.2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

enum ProfileAvatarUpdateInfo { case avatar(UIImage), name(String) }

// MARK: - ConversationsRepositoryProtocol
protocol ConversationsRepositoryProtocol {
    var conversations: Dynamic<[Conversation]> { get }
    
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func updateConversationsOnce(completion: @escaping (Bool) -> Void)
    func addConversation(with name: String?,
                         completion: ResultHandler<String>)
    func deleteConversation(withID id: String?,
                            completion: @escaping ResultHandler<String>)
    
    func fetchAvatarOrName(completion: @escaping ResultHandler<ProfileAvatarUpdateInfo>)
}

final class ConversationsRepository: ConversationsRepositoryProtocol {
    
    // MARK: - Properties
    private var isFirstFetch = true
    
    private let cloudStore: FirestoreManager<Conversation>
    private let cdContextProvider: CDContextProviderProtocol
    
    let conversations: Dynamic<[Conversation]> = Dynamic([])
    
    let fileManager: AsyncFileManagerProtocol
    let fmPreferences: FileManagerPreferences
    
    // MARK: - Init
    init(fileManager: AsyncFileManagerProtocol = GCDFileManager(),
         fmPreferences: FileManagerPreferences = FileManagerPreferences(
            textExtension: .txt,
            imageExtension: .jpeg(1.0),
            directory: .userProfile),
         cloudStore: FirestoreManager<Conversation> = FirestoreManager<Conversation>(
            collectionName: FBCollections.channels.rawValue
         ),
         cdContextProvider: CDContextProviderProtocol = CDContextProvider.shared
    ) {
        self.fileManager = fileManager
        self.fmPreferences = fmPreferences
        self.cloudStore = cloudStore
        self.cdContextProvider = cdContextProvider
    }
    
    private func bindCloudWithModel() {
        self.cloudStore.model.bind { [weak self] conversations in
            self?.conversations.value = conversations
        }
    }
}

// MARK: - CloudStore Methods
extension ConversationsRepository {
    
    // MARK: Print Update Log
    private func printUpdateLog(updateLog: CSModelUpdateLog<Conversation>?) {
        // Логирование не включено, или updateLog пустой
        guard let updateLog = updateLog else { return }
        print("🔥 [FirestoreUpdate]: Documents added: \(updateLog.addedCount) modified: \(updateLog.updatedCount) removed: \(updateLog.removedCount)")
    }
    
    // MARK: Subscribe to stream
    func subscribeToUpdates() {
        bindCloudWithModel()
        isFirstFetch = true
        cloudStore.subscribeToUpdates(enableLogging: true) { [weak self] result in
            switch result {
            case .success(let updateLog):
                self?.printUpdateLog(updateLog: updateLog)
                // Передаем изменения CoreDat'е
                self?.updateCoreData(with: updateLog)
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func unsubscribeFromUpdates() {
        cloudStore.unsubscribeFromUpdates()
    }
    
    // MARK: Update Conversations Once
    func updateConversationsOnce(completion: @escaping (Bool) -> Void) {
        cloudStore.updateModel(enableLogging: true) { _ in
            completion(true)
        }
    }
    
    // MARK: Add Conversation
    func addConversation(with name: String?,
                         completion: ResultHandler<String>) {
        guard let name = name,
              name.isntEmptyOrWhitespaced else {
                  completion(.failure(FirestoreError.emptyString))
                  return
              }
        
        let conversation = Conversation(name: name)
        
        cloudStore.addEntity(from: conversation) { result in
            switch result {
            case .success:
                completion(
                    .success("Беседа с именем \(name) успешно создана!")
                )
            case .failure(let error):
                completion(
                    .failure(error)
                )
            }
        }
    }
    
    // MARK: DeleteConversation
    func deleteConversation(withID id: String?,
                            completion: @escaping ResultHandler<String>) {
        guard let id = id, id != "" else {
            completion(.failure(FirestoreError.emptyString))
            return
        }
        
        cloudStore.deleteEntity(withID: id) { result in
            switch result {
            case .success:
                completion(
                    .success("Беседа успешно удалена из списка каналов!")
                )
            case .failure(let error):
                completion(
                    .failure(error)
                )
            }
        }
    }
}

// MARK: - FileManager Operatable Methods
extension ConversationsRepository: FMImageOperatable, FMStringOperatable {
    
    // MARK: Fetch Avatar or Name
    func fetchAvatarOrName(completion: @escaping ResultHandler<ProfileAvatarUpdateInfo>) {
        /*
         Ищем аватарку пользователя
         если ее нет - возвращаем имя для генерации плейсхолдера
         если и имя пустое - то ошибка
         */
        fetchImage(key: AppFileNames.userAvatar.rawValue) { [weak self] result in
            if case .success(let image) = result {
                DispatchQueue.main.async {
                    completion(.success(.avatar(image)))
                }
            } else {
                self?.fetchString(key: AppFileNames.userName.rawValue) { result in
                    if case .success(let name) = result {
                        DispatchQueue.main.async {
                            completion(.success(.name(name)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(FMError.fileNotFound))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Core Data Methods
extension ConversationsRepository {
    
    // MARK: Save changes to Core Data
    private func updateCoreData(with updateLog: CSModelUpdateLog<Conversation>?) {
        guard let updateLog = updateLog else { return }
    
        // Создаем воркера в бекграунд треде
        let saveWorker = CDWorker<Conversation, DBChannel>(
            context: cdContextProvider.newBackgroundContext,
            mergePolicy: .mergeByPropertyObjectTrumpMergePolicyType
        )
        
        // Если мы только что подписались на изменения - чистим базу, и перезаписываем
        // так как мы не можем знать какие изменения там произошли с прошлого запуска
        if isFirstFetch {
            saveWorker.coreDataManager.removeAllAndSave { [weak self] _ in
                self?.isFirstFetch = false
            }
        }
        
        if updateLog.addedCount != 0 {
            saveWorker.coreDataManager.insert(updateLog.addedObjects)
        }
        
        if updateLog.updatedCount != 0 {
            // При выбранной merge политике, insert должен работать как update
            saveWorker.coreDataManager.insert(updateLog.updatedObjects)
        }
        
        if updateLog.removedCount != 0 {
            for object in updateLog.removedObjects {
                guard let id = object.identifier else { continue }
                saveWorker.coreDataManager.removeEntity(withID: id)
            }
        }
        
        saveWorker.saveIfNeeded()
    }
}
