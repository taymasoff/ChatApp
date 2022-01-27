//
//  GridImagesAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.11.2021.
//

import UIKit

/// Сборщик компонентов модуля экрана выбора картинки
class GridImagesAssembler {
    
    struct Configuration {
        let delegate: GridImagesCollectionDelegate? = nil
        let numberOfColumns: Int = 3
        let layoutSpacing: CGFloat = 4
    }
    
    private let configuration: Configuration
    let container: DIContainer
    
    init(container: DIContainer,
         configuration: GridImagesAssembler.Configuration) {
        self.container = container
        self.configuration = configuration
    }
    
    func assembleAll() {
        assembleRepository()
        assembleLayout()
        assembleViewModel()
        assembleViewController()
    }
    
    func assembleViewController() {
        container.register(type: GridImagesCollectionViewController.self) { container in
            return GridImagesCollectionViewController(
                viewModel: container.resolve(type: GridImagesCollectionViewModel.self),
                layout: container.resolve(type: PinterestLayout.self),
                enableSearchBar: true
            )
        }
    }
    
    func assembleViewModel() {
        container.register(type: GridImagesCollectionViewModel.self) { container in
            return GridImagesCollectionViewModel(
                repository: container.resolve(type: GridImagesRepository.self),
                imageIfFailed: nil,
                delegate: self.configuration.delegate
            )
        }
    }
    
    func assembleLayout() {
        container.register(type: PinterestLayout.self) { _ in
            return PinterestLayout(
                numberOfColumns: self.configuration.numberOfColumns,
                spacing: self.configuration.layoutSpacing
            )
        }
    }
    
    func assembleRepository() {
        container.register(type: GridImagesRepository.self) { container in
            return GridImagesRepository(
                requestDispatcher: container.resolve(type: RequestDispatcher.self),
                imageFetcher: container.resolve(type: CachedImageFetcher.self)
            )
        }
    }
}
