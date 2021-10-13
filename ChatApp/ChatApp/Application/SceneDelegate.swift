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

    // MARK: - UIWindowSceneDelegate Lifecycle Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        let navController = UINavigationController()
        let router = MainRouter(navigationController: navController)
        router.initiateFirstViewController()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

