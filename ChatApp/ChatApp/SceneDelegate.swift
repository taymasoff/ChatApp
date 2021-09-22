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
        
        print("\(#function) - Scene is Connected to the App")
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("\(#function) - Scene has been Removed from the App")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("\(#function) - Scene has become Active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("\(#function) - Scene is about to leave an Active state and become Inactive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("\(#function) - Scene is entering Foreground state")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("\(#function) - Scene has entered Background state")
    }
}

