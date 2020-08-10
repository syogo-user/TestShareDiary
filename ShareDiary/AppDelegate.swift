//
//  AppDelegate.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //SVProgressHUDを使用するための設定
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //スライダー設定
        let tabBarController = TabBarController.init(nibName: "tabbar", bundle: nil)
        let leftViewController = LeftViewController.init(nibName: "Left", bundle: nil)
        let slideMenuController = SlideMenuController(mainViewController:tabBarController as UIViewController, leftMenuViewController: leftViewController)
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    
}

