//
//  DynamicPreservable.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.10.2021.
//

import Foundation

/*
 👉 Немного модифицированный Dynamic для удобства работы с 2-мя состояниями переменной
 */

/// Обертка для байндинга с возможностью сохранять состояние,
///  - .value для доступа к переменной
///  - .bind для привязки
///  - .preserve для сохранения последнего состояния value
///  - .restore для восстановления сохранненого состояния value
///  - .hasChanged - изменилось ли состояние
class DynamicPreservable<T: Equatable>: Dynamic<T> {
    typealias UpdatesListener = ((Bool) -> Void)
    var updatesListener: UpdatesListener?
    
    private(set) var preservedValue: T
    
    override var value: T {
        didSet {
            listener?(value)
            updatesListener?(hasChanged())
        }
    }
    
    override init(_ value: T, id: String? = nil) {
        preservedValue = value
        super.init(value, id: id)
    }
    
    func bindUpdates(updatesListener: UpdatesListener?) {
        self.updatesListener = updatesListener
    }
    
    func preserve() {
        preservedValue = value
        updatesListener?(hasChanged())
    }
    
    func setAndPreserve(_ value: T) {
        self.preservedValue = value
        self.value = value
    }
    
    func restore() {
        value = preservedValue
    }
    
    func hasChanged() -> Bool {
        return value != preservedValue
    }
}
