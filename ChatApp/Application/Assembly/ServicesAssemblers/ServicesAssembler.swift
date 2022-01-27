//
//  ServicesAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import Foundation

/// Сборщик серисов приложения
class ServicesAssembler {
    
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

// MARK: - File Manager Assembly
extension ServicesAssembler {
    enum FileManagerType { case gcd, operation, both }
    
    func assembleFileManager(ofType type: FileManagerType) {
        switch type {
        case .gcd:
            assembleGCDFileManager()
        case .operation:
            assembleOperationsFileManager()
        case .both:
            assembleGCDFileManager()
            assembleOperationsFileManager()
        }
    }
    
    private func assembleGCDFileManager() {
        container.register(type: GCDFileManager.self) { _ in
            return GCDFileManager(fileManager: FileManager.default,
                                  qos: .default)
        }
    }
    
    private func assembleOperationsFileManager() {
        container.register(type: OperationFileManager.self) { _ in
            return OperationFileManager(fileManager: FileManager.default,
                                        qos: .default)
        }
    }
}

// MARK: - ImagePicker Assembly
extension ServicesAssembler {
    func assembleImagePicker() {
        container.register(type: ImagePickerManager.self, asSingleton: true) { container in
            return ImagePickerManager(
                gridImagesController: container.resolve(
                    type: GridImagesCollectionViewController.self
                )
            )
        }
    }
}

// MARK: - GridImagesModule Assembly
extension ServicesAssembler {
    func assembleGridImagesModule() {
        let gridImagesAssembler = GridImagesAssembler(
            container: container,
            configuration: .init()
        )
        gridImagesAssembler.assembleAll()
    }
}

// MARK: - RequestDispatcher Assembly
extension ServicesAssembler {
    func assembleRequestDisptacher() {
        container.register(type: RequestDispatcher.self) { _ in
            return RequestDispatcher(urlSession: URLSession.shared)
        }
    }
}

// MARK: - ImageFetcher Assembly
extension ServicesAssembler {
    func assembleImageFetcher() {
        container.register(type: CachedImageFetcher.self) { _ in
            return CachedImageFetcher()
        }
    }
}

extension ServicesAssembler {
    func assembleImageRetriever() {
        container.register(type: ImageRetriever.self) { container in
            return ImageRetriever(
                imageFetcher: container.resolve(type: CachedImageFetcher.self)
            )
        }
    }
}
