//
//  DMRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

typealias DMRepositoryFSOperatable = FSSubscribable & FSAddable

// MARK: - ConversationsRepositoryProtocol
protocol DMRepositoryProtocol {
    var model: Dynamic<[Message]> { get }
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func newMessage(with content: String?)
}

final class DMRepository: DMRepositoryProtocol {
    
    // MARK: - Properties
    let db = Firestore.firestore()
    let reference: CollectionReference
    var listener: ListenerRegistration?
    
    let model: Dynamic<[Message]> = Dynamic([])
    
    init(with dialogueID: String) {
        self.reference = db.collection(FBCollections.channels.rawValue).document(dialogueID).collection(FBCollections.messages.rawValue)
    }
}

// MARK: - DMRepository Firestore Operatable
extension DMRepository: DMRepositoryFSOperatable {
    // MARK: - Subscribe to stream
    func subscribeToUpdates() {
        subscribeToUpdates { updateLog, error in
            guard error == nil else { Log.error(error!.localizedDescription); return }
            if let updateLog = updateLog { print(updateLog) }
        }
    }
    
    // MARK: - Add Conversation
    func newMessage(with content: String?) {
        guard let content = content,
              content.isntEmptyOrWhitespaced() else {
                  Log.error("Невозможно создать сообщение с пустым контентом.")
                  return
              }
        
        let message = Message(content: content)
        
        addDocument(from: message) { result in
            switch result {
            case .success(let message):
                Log.info(message)
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
}
