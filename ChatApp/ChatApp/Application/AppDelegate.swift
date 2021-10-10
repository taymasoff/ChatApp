//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - UIApplicationDelegate Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupNavigationBarAppearance()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = AppAssets.colors(.appMain)
        let navController = UINavigationController()
        let moduleBuilder = ModuleBuilder()
        let router = MainRouter(navigationController: navController,
                                moduleBuilder: moduleBuilder)
        router.initiateFirstViewController()
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
    
    /// Настраивает дефолтное отображение UINavigationBar в приложении
    func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = AppAssets.colors(.appGray)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: AppAssets.font(.sfProText, type: .regular, size: 20)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black, .font: AppAssets.font(.sfProDisplay, type: .bold, size: 34)]

            UINavigationBar.appearance().tintColor = .systemBlue
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .systemBlue
            UINavigationBar.appearance().barTintColor = AppAssets.colors(.appGray)
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

