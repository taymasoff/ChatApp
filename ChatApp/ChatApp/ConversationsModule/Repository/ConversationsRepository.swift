//
//  ConversationsRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.10.2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

// MARK: - ConversationsRepositoryProtocol
protocol ConversationsRepositoryProtocol {
    var conversations: Dynamic<[Conversation]> { get }
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
}

final class ConversationsRepository: ConversationsRepositoryProtocol {
    
    private lazy var db = Firestore.firestore()
    private lazy var channelsReference = db.collection(FBCollections.channels.rawValue)
    private var listener: ListenerRegistration?
    
    let conversations: Dynamic<[Conversation]> = Dynamic([])
    
    func subscribeToUpdates() {
        listener = channelsReference.addSnapshotListener { [weak self] snapshot, error in
            guard error == nil else {
                Log.error(error.debugDescription)
                return
            }
            
            self?.conversations.value = snapshot?.documents
                .compactMap { (document) -> Conversation? in
                    if var conversation = try? document.data(as: Conversation.self) {
                        // id не декодится, т.к. он отдельно, поэтому вставляем вручную
                        conversation.identifier = document.documentID
                        return conversation
                    } else {
                        return nil
                    }
                } ?? []
        }
    }
    
    func unsubscribeFromUpdates() {
        _ = listener?.remove()
    }
}
