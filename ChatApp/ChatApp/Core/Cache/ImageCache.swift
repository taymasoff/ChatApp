//
//  ImageCacheProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 24.11.2021.
//

import Foundation

protocol ImageCacheProtocol: AnyObject {
    
    /// Метод, возвращающий изображение по его URL
    func image(for url: String) -> UIImage?
    
    /// Метод, устанавливающий изображение по ключу URL
    func insertImage(_ image: UIImage?, for url: String)
    
    /// Метод, удаляющий изображение по ключу URL
    func removeImage(for url: String)
    
    /// Метод очищающий кэш
    func clearCache()
    
    /// Сабскрипт для быстрого доступа записи/чтения
    subscript(_ url: String) -> UIImage? { get set }
}


class ImageCache: ImageCacheProtocol {
    
    /// Кэш изображений
    private let imageCache: NSCache<NSString, UIImage>
    
    /// Лок, чтобы избежать проблем с многопоточностью
    private let lock = NSLock()
    
    /// Инициализатор кэша
    /// - Parameters:
    ///   - countLimit: максимальное количество хранимых картинок (100 по умолчанию)
    ///   - mbMemoryLimit: максимальный объем кэша в мегабайтах (100 по умолчанию)
    init(countLimit: Int = 100, mbMemoryLimit: Int = 100) {
        self.imageCache = NSCache<NSString, UIImage>()
        self.imageCache.countLimit = countLimit
        self.imageCache.totalCostLimit = 1024 * 1024 * mbMemoryLimit
    }
    
    func image(for url: String) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        guard let image = imageCache.object(forKey: url as NSString) else {
            return nil
        }
        return image
    }
    
    func insertImage(_ image: UIImage?, for url: String) {
        guard let image = image else { return removeImage(for: url) }
        lock.lock(); defer { lock.unlock() }
        imageCache.setObject(image, forKey: url as NSString)
    }
    
    func removeImage(for url: String) {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeObject(forKey: url as NSString)
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
    }
    
    subscript(url: String) -> UIImage? {
        get {
            return image(for: url)
        }
        set {
            return insertImage(newValue, for: url)
        }
    }
}
