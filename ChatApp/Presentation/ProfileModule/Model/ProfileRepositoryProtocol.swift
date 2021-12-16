//
//  ProfileRepositoryProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import Foundation

/// Operation Success Status
enum OperationSuccess {
    case allGood(String)
    case hadErrors(String)
}

protocol ProfileRepositoryProtocol {
    var user: Dynamic<User?> { get }
    func saveUserSeparately(_ user: User,
                            completion: @escaping ResultHandler<OperationSuccess>)
    func fetchUser(completion: @escaping ResultHandler<OperationSuccess>)
}
