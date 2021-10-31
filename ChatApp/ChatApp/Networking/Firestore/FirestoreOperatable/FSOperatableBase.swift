//
//  FSOperatableBase.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 31.10.2021.
//

import Foundation
import FirebaseFirestore

/// Базовый протокол для поддержки протоколов семейства FirestoreOperatable
protocol FSOperatableBase: AnyObject {
    associatedtype ModelType
    var db: Firestore { get }
    var reference: CollectionReference { get }
    var model: Dynamic<[ModelType]> { get }
}
