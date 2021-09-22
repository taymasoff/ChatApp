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
        
        Log.info("App just Launched")
        
        return true
    }
    
    // Методы жизненного цикла приложения были заменены на методы жизненного цикла UIScene
    // Методы ниже не работают с iOS 13
    func applicationDidBecomeActive(_ application: UIApplication) {
        Log.info("App has become Active")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Log.info("App is about to leave an Active state and become Inactive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Log.info("App is now in Background state")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Log.info("App is entering Foreground state")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Log.info("App is about to Terminate")
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

