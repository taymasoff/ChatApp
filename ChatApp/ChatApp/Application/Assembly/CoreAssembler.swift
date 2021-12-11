//
//  CoreAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import Foundation

/// Сборщик базовых компонентов приложения
class CoreAssembler {
    
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

// MARK: - File Manager Assembly
extension CoreAssembler {
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
