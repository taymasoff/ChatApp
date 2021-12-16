//
//  GridPresentableImage.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.11.2021.
//

import Foundation

/// Протокол требующий от модели  минимальные параметры для корректной отрисовки в GridImageCollection
protocol GridPresentableImage {
    var previewImageURL: String { get }
    var fullImageURL: String { get }
    var imageHeight: CGFloat { get }
    var imageWidth: CGFloat { get }
}
