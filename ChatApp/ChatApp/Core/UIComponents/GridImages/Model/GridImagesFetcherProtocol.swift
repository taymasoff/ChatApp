//
//  GridImagesFetcherProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 21.11.2021.
//

import UIKit

/// Протокол определяющий необходимые свойства и методы для подгрузки изображений в GridImageCollection
protocol GridImagesFetcherProtocol {
        
    /// Обновить список моделей с первой страницы
    /// - Parameter query: поисковый запрос в виде строки
    func fetchImagesList(query: String?,
                         completion: @escaping ResultHandler<[GridPresentableImage]>)
    
    /// Обновить список, добавив результаты следующей страницы
    func fetchMoreImages(completion: @escaping ResultHandler<[GridPresentableImage]>)
    
    /// Загрузить изображение низкого качества для превью
    /// - Parameter url: ссылка на изображение
    func fetchPreviewImage(byURL url: String,
                           completion: @escaping ResultHandler<UIImage>)
    
    /// Загрузить изображение высокого качества
    /// - Parameter url: ссылка на изображение
    func fetchFullImage(byURL url: String,
                        completion: @escaping ResultHandler<UIImage>)
}
