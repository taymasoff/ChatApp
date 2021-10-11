//
//  Protocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation
import UIKit

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
