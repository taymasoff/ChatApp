//
//  DIContainer.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import Foundation

typealias FactoryClosure = (DIContainer) -> AnyObject

class DIContainer {
    var services = [String: FactoryClosure]()
    var singletons = [String: AnyObject]()
    
    /// Сохранить инициализацию сервиса в контейнере.
    /// - Parameter type: тип зарегистрированного сервиса
    /// - Parameter asSingleton: если true - сервис также инициализируется и сохраняется в контейнере
    /// - Parameter factoryClosure: замыкание, ожидающее инициализацию сервиса
    func register<Service>(type: Service.Type,
                           asSingleton: Bool = false,
                           factoryClosure: @escaping FactoryClosure) {
        services["\(type)"] = factoryClosure
        if asSingleton {
            singletons["\(type)"] = factoryClosure(self)
        }
    }
    
    /// Найти сервис в контейнере и инициализировать его
    /// - Parameter type: тип зарегистрированного сервиса
    /// - Parameter asSingleton: если true - сервис достается из коллекции зарегистрированных ранее объектов
    /// - Returns: опциональный сервис переданного типа
    func resolve<Service>(type: Service.Type, asSingleton: Bool = false) -> Service? {
        if asSingleton,
        let service = singletons["\(type)"] as? Service {
            return service
        } else {
            return services["\(type)"]?(self) as? Service
        }
    }
    
    /// Найти сервис в контейнере и инициализировать его. Если сервис не найден - выйдет fatalError
    /// - Parameter type: тип зарегистрированного сервиса
    /// - Parameter asSingleton: если true - сервис достается единожды и используется как синглтон
    /// - Returns: сервис переданного типа
    func resolve<Service>(type: Service.Type, asSingleton: Bool = false) -> Service {
        guard let service = self.resolve(type: type, asSingleton: asSingleton) else {
            fatalError("Couldn't resolve \(type.self)")
        }
        return service
    }
}
