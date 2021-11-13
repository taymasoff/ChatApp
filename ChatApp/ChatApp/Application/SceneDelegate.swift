//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit
import Rswift

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var diContainer = DIContainer()

    // MARK: - UIWindowSceneDelegate Lifecycle Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let appAssembler = AppAssembler(contaier: diContainer)
        appAssembler.assembleMainRouter()
        createAndShowFirstScene(scene: scene,
                                router: diContainer
                                    .resolve(type: MainRouter.self,
                                             asSingleton: true))
    }
    
    private func createAndShowFirstScene(scene: UIScene, router: MainRouterProtocol) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        router.initiateFirstViewController()
        window?.rootViewController = router.navigationController
        window?.makeKeyAndVisible()
    }
}
