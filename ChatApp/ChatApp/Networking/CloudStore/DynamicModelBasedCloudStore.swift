//
//  DynamicModelBasedCloudStore.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.11.2021.
//

import Foundation

/// Тип, утверждающий о наличии динамической модели данных в облачном хранилище
protocol DynamicModelBasedCloudStore {
    associatedtype ModelType
    
    var model: Dynamic<[ModelType]> { get set }
}
