//
//  Protocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation
import UIKit
import CoreData

// MARK: - ResultHandler With Generic Result
typealias ResultHandler<T> = (Result<T, Error>) -> Void

// MARK: - Routable
/// Протокол, которому соответствуют все объекты, имеющие возможность совершать переходы в приложении
protocol Routable {
    var router: MainRouterProtocol { get }
}

// MARK: - ViewModelBased
/// Протокол, которому соответствуют все классы, зависящие от вью-модели
protocol ViewModelBased: AnyObject {
    associatedtype ViewModel
    var viewModel: ViewModel? { get set }
}

// MARK: - ViewModelBindable
/// Протокол, которому соответствуют все классы, зависящие от вью-модели и имеющие функцию bindWithViewModel()
protocol ViewModelBindable: ViewModelBased {
    func bindWithViewModel()
}

// MARK: - Configurable
/// Протокол, которому соответствуют все объекты, имеющие функцию configure(with model)
protocol Configurable {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

// MARK: - ConfigurableView+ViewModelBindable Default Implementation
extension Configurable where Self: ViewModelBindable {
    func configure(with: ViewModel) {
        self.viewModel = with
        bindWithViewModel()
    }
}

// MARK: - ReuseIdentifiable
/// Протокол, которому соответствуют все объекты, имеющие статическую переменную reuseID
protocol ReuseIdentifiable {
    static var reuseID: String { get }
}

// MARK: - IdentifiableView Default Implementation
extension ReuseIdentifiable {
    static var reuseID: String {
        return String(describing: Self.self)
    }
}

// MARK: - Managed Object Model
protocol ManagedObjectModel: CDIdentifiable {
    associatedtype DomainModel
    
    func toDomainModel() -> DomainModel
}

// MARK: - Domain Model
protocol DomainModel: CDIdentifiable {
    associatedtype Entity
    
    @discardableResult
    func insertInto(entity: Entity) -> Entity
}

// MARK: - Core Data Identifiable
protocol CDIdentifiable {
    var uniqueSearchString: String? { get }
    var uniqueSearchPredicate: NSPredicate? { get }
}

// MARK: - Fire Store Identifiable
protocol FSIdentifiable {
    var identifier: String? { get set }
}
}
