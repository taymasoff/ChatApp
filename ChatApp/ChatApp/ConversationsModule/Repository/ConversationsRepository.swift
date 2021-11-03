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
    let cloudStore: FirestoreManager<Conversation>
    
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
         )
    ) {
        self.fileManager = fileManager
        self.fmPreferences = fmPreferences
        self.cloudStore = cloudStore
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
    
    func unsubscribeFromUpdates() {
        cloudStore.unsubscribeFromUpdates()
    }
    
    // MARK: Update Conversations Once
    func updateConversationsOnce(completion: @escaping (Bool) -> Void) {
        cloudStore.updateModel { result in
            switch result {
            case .success(let message):
                print(message)
                completion(true)
            case .failure(let error):
                Log.error(error)
                completion(false)
            }
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
