//
//  StoredProperty.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.10.2021.
//

import Foundation

/*
 PropertyWrapper для работы с UserDefaults
 */

@propertyWrapper
struct StoredProperty<T: RawRepresentable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) else {
                 return defaultValue
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
