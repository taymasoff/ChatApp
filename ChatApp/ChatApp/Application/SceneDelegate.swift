//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit

/*
 C iOS 13 и выше контроль жизненного цикла приложения перешел к UIScene.
 В приложении может быть несколько сцен и у каждой может быть свой жизненный цикл.
 */

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate Lifecycle Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
            window?.backgroundColor = AppAssets.colors(.appMain)
            let navController = UINavigationController()
            let moduleBuilder = ModuleBuilder()
            let router = MainRouter(navigationController: navController,
                                    moduleBuilder: moduleBuilder)
            router.initiateFirstViewController()
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
    }
}

