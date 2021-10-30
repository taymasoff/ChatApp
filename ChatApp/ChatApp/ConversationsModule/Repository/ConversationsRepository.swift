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
    // Firestore Operations
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func updateConversationsOnce(completion: @escaping () -> Void)
    func addConversation(with name: String?,
                         completion: CompletionHandler<String>)
    func deleteConversation(withID id: String?,
                            completion: @escaping CompletionHandler<String>)
    // FileManager Operations
    func fetchAvatarOrName(completion: @escaping CompletionHandler<ProfileAvatarUpdateInfo>)
}

final class ConversationsRepository: ConversationsRepositoryProtocol {
    
    // MARK: - Properties
    private lazy var db = Firestore.firestore()
    private lazy var channelsReference = db.collection(FBCollections.channels.rawValue)
    private var listener: ListenerRegistration?
    
    let conversations: Dynamic<[Conversation]> = Dynamic([])
    let fileManager: AsyncFileManagerProtocol
    let fmPreferences: FileManagerPreferences
    
    // MARK: - Init
    init(fileManager: AsyncFileManagerProtocol = GCDFileManager(),
         fmPreferences: FileManagerPreferences = FileManagerPreferences(
            .txt,
            .jpeg(1.0),
            .userProfile)
    ) {
        self.fileManager = fileManager
        self.fmPreferences = fmPreferences
    }
    
    // MARK: - Subscribe to stream
    func subscribeToUpdates() {
        listener = channelsReference.addSnapshotListener { [weak self] snapshot, error in
            guard error == nil else {
                Log.error(error.debugDescription)
                return
            }
            
            self?.conversations.value = snapshot?.documents
                .compactMap { (document) -> Conversation? in
                    if var conversation = try? document.data(as: Conversation.self) {
                        // id не декодится, т.к. он берется из documentID,
                        // поэтому вставляем вручную
                        conversation.identifier = document.documentID
                        return conversation
                    } else {
                        return nil
                    }
                } ?? []
        }
    }
    
    // MARK: - Unsubscribe from stream
    func unsubscribeFromUpdates() {
        _ = listener?.remove()
    }
    
    // MARK: - Update Conversations Once
    func updateConversationsOnce(completion: @escaping () -> Void) {
        channelsReference.getDocuments { [weak self] snapshot, error in
            guard error == nil else {
                Log.error(error.debugDescription)
                return
            }
            
            self?.conversations.value = snapshot?.documents
                .compactMap { (document) -> Conversation? in
                    if var conversation = try? document.data(as: Conversation.self) {
                        conversation.identifier = document.documentID
                        return conversation
                    } else {
                        return nil
                    }
                } ?? []
            
            completion()
        }
    }
    
    // MARK: - Add Conversation
    func addConversation(with name: String?,
                         completion: CompletionHandler<String>) {
        guard let name = name,
              name.isntEmptyOrWhitespaced() else {
                  completion(.failure(FirestoreError.emptyString))
                  return
              }
        
        let conversation = Conversation(name: name)
        
        do {
            _ = try channelsReference.addDocument(from: conversation)
            completion(
                .success("Новая беседа с именем \(name) успешно создана!")
            )
        } catch {
            completion(.failure(FirestoreError.documentAddError))
        }
    }
    
    func deleteConversation(withID id: String?,
                            completion: @escaping CompletionHandler<String>) {
        guard let id = id, id != "" else {
            completion(.failure(FirestoreError.emptyString))
            return
        }
        
        channelsReference.document(id).delete { error in
            if let error = error {
                completion(
                    .failure(error)
                )
            } else {
                completion(
                    .success("Беседа успешно удалена из списка каналов!")
                )
            }
        }
    }
}

// MARK: - FileManager Operatable Methods
extension ConversationsRepository: FMImageOperatable, FMStringOperatable {
    
    // MARK: Fetch Avatar or Name
    func fetchAvatarOrName(completion: @escaping CompletionHandler<ProfileAvatarUpdateInfo>) {
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
