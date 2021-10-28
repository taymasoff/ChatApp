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
    func newMessage(with content: String?,
                    completion: CompletionHandler<String>)
}

final class DMRepository: DMRepositoryProtocol {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let messagesReference: CollectionReference
    private var listener: ListenerRegistration?
    
    let messages: Dynamic<[Message]> = Dynamic([])
    
    init(with dialogueID: String) {
        self.messagesReference = db.collection(FBCollections.channels.rawValue).document(dialogueID).collection(FBCollections.messages.rawValue)
    }
    
    // MARK: - Subscribe to stream
    func subscribeToUpdates() {
        listener = messagesReference.addSnapshotListener { [weak self] snapshot, error in
            guard error == nil else {
                Log.error(error.debugDescription)
                return
            }
            
            self?.messages.value = snapshot?.documents
                .compactMap { (document) -> Message? in
                    if let message = try? document.data(as: Message.self) {
                        return message
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
    
    // MARK: - Add Conversation
    func newMessage(with content: String?,
                    completion: CompletionHandler<String>) {
        guard let content = content,
              content.isntEmptyOrWhitespaced() else {
                  completion(.failure(FirestoreError.emptyString))
                  return
              }
        
        let message = Message(content: content)
        
        do {
            _ = try messagesReference.addDocument(from: message)
            completion(
                .success("Сообщение успешно отправлено")
            )
        } catch {
            completion(.failure(FirestoreError.documentAddError))
        }
    }
}
