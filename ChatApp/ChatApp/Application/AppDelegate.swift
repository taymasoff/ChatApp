//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit
import Rswift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - UIApplicationDelegate Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        setupLogger()
        
        logCoreData()
        
        ThemeManager.updateCurrentTheme()
        if #available(iOS 13, *) {} else {
            createAndShowFirstScene()
        }
        return true
    }
    
    private func logCoreData() {
        let context = CDContextProvider.shared.mainContext
        let cWorker = CDWorker<Conversation, DBChannel>(context: context)
        guard let channels = try? cWorker.coreDataManager.fetchEntities() else {
            return
        }
        channels.forEach {
            print("🗄 [CDChannel]: \($0.name) have \($0.messages?.count ?? 0) messages.")
        }
    }
    
    private func setupLogger() {
        Log.setup(loggerState: .onlyInDebug,
                  includeDate: true,
                  includeFileNames: true,
                  includeFuncNames: true)
    }
    
    // MARK: - Create and Show First Scene
    private func createAndShowFirstScene() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        let navController = UINavigationController()
        let router = MainRouter(navigationController: navController)
        router.initiateFirstViewController()
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
        
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
