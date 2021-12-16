//
//  ProfileModuleAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 13.11.2021.
//

import Foundation

/// Сборщик компонентов модуля профиля
class ProfileModuleAssembler {
    
    struct Configuration {
        let profileDelegate: ProfileDelegate?
        let fmPreferences: FileManagerPreferences
    }
    
    private let configuration: Configuration
    let container: DIContainer
    
    init(container: DIContainer,
         configuration: ProfileModuleAssembler.Configuration) {
        self.container = container
        self.configuration = configuration
    }
    
    func assembleAll() {
        assembleRepository()
        assembleViewModel()
        assembleProfileView()
        assembleViewController()
    }
    
    func assembleViewController() {
        container.register(type: ProfileViewController.self) { container in
            return ProfileViewController(
                with: container.resolve(type: ProfileViewModel.self),
                profileView: container.resolve(type: ProfileView.self)
            )
        }
    }
    
    func assembleProfileView() {
        container.register(type: ProfileView.self) { _ in
            return ProfileView()
        }
    }
    
    func assembleViewModel() {
        container.register(type: ProfileViewModel.self) { container in
            return ProfileViewModel(
                router: container.resolve(type: MainRouter.self, asSingleton: true),
                repository: container.resolve(type: ProfileRepository.self),
                delegate: self.configuration.profileDelegate,
                imagePicker: container.resolve(type: ImagePickerManager.self,
                                               asSingleton: true)
            )
        }
    }
    
    func assembleRepository() {
        container.register(type: ProfileRepository.self) { container in
            return ProfileRepository(
                fileManager: container.resolve(type: GCDFileManager.self),
                fmPreferences: self.configuration.fmPreferences
            )
        }
    }
}
