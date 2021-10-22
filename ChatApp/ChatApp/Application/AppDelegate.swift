//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit
import Rswift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - UIApplicationDelegate Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupNavigationBarAppearance()
        initWindowAndFirstScreen()
        return true
    }
    
    
    private func initWindowAndFirstScreen() {
        if #available(iOS 13, *) {} else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = R.color.appMain()
            let navController = UINavigationController()
            let router = MainRouter(navigationController: navController)
            router.initiateFirstViewController()
            window.rootViewController = navController
            window.makeKeyAndVisible()
            self.window = window
        }
    }
    
    /// Настраивает дефолтное отображение UINavigationBar в приложении
    private func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = R.color.appGray()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black,
                                              .font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black,
                                                    .font: UIFont.systemFont(ofSize: 30, weight: .bold)]

            UINavigationBar.appearance().tintColor = .systemBlue
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .systemBlue
            UINavigationBar.appearance().barTintColor = R.color.appGray()
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

