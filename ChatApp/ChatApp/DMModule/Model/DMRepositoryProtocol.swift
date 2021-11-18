//
//  DMRepositoryProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import Foundation

protocol DMRepositoryProtocol {
    func subscribeToUpdates()
    func unsubscribeFromUpdates()
    func newMessage(with content: String?)
}
