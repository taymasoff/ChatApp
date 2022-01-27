//
//  AppAssembly.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.11.2021.
//

import UIKit

/// Главный сборщик приложения
class AppAssembler {
    
    // MARK: - Properties
    let container: DIContainer
    private lazy var servicesAssembler = ServicesAssembler(container: container)
    
    private lazy var userProfileFMPreferences = FileManagerPreferences(
        textExtension: .txt,
        imageExtension: .jpeg(1.0),
        directory: .userProfile
    )
    
    // MARK: - Init
    init(contaier: DIContainer = DIContainer()) {
        self.container = contaier
    }
    
    // MARK: - Startup Assemble
    func startupAssemble() {
        assembleMainRouter()
        servicesAssembler.assembleFileManager(ofType: .gcd)
        servicesAssembler.assembleRequestDisptacher()
        servicesAssembler.assembleImageFetcher()
        servicesAssembler.assembleGridImagesModule()
        servicesAssembler.assembleImagePicker()
        servicesAssembler.assembleImageRetriever()
        assembleConversationsModule()
    }
    
    // MARK: - Assemble Methods
    func assembleMainRouter() {
        container.register(type: MainRouter.self,
                           asSingleton: true) { _ in
            let navigationController = UINavigationController()
            return MainRouter(navigationController: navigationController,
                              appAssembler: self)
        }
    }
    
    func assembleConversationsModule() {
        let conversationsModuleAssembler = ConversationsModuleAssembler(
            container: container,
            configuration: .init(fmPreferences: userProfileFMPreferences)
        )
        conversationsModuleAssembler.assembleAll()
    }
    
    func assembleDMModule(dialogueID: String, chatName: String?, chatImage: UIImage?) {
        let dmModuleAssembler = DMModuleAssembler(
            container: container,
            configuration: .init(dialogueID: dialogueID,
                                 chatName: chatName,
                                 chatImage: chatImage)
        )
        dmModuleAssembler.assembleAll()
    }
    
    func assembleProfileModule(delegate: ProfileDelegate?) {
        let profileModuleAssembler = ProfileModuleAssembler(
            container: container,
            configuration: .init(profileDelegate: delegate,
                                 fmPreferences: userProfileFMPreferences)
        )
        profileModuleAssembler.assembleAll()
    }
    
    func assembleThemesModule(onThemeChanged: @escaping (UIColor) -> Void) {
        let themesModuleAssembler = ThemesModuleAssembler(
            container: container,
            configuration: .init(onThemeChanged: onThemeChanged)
        )
        themesModuleAssembler.assembleAll()
    }
}
