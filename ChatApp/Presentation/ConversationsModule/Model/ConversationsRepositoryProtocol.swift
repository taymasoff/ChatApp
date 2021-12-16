//
//  ConversationsRepositoryProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import Foundation

enum ProfileAvatarUpdateInfo { case avatar(UIImage), name(String) }

protocol ConversationsRepositoryProtocol {
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func updateConversationsOnce(completion: @escaping (Bool) -> Void)
    func addConversation(with name: String?,
                         completion: ResultHandler<String>)
    func deleteConversation(withID id: String?,
                            completion: @escaping ResultHandler<String>)
    
    func fetchAvatarOrName(completion: @escaping ResultHandler<ProfileAvatarUpdateInfo>)
}
