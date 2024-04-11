//
//  AppDelegate.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 07.04.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let mainCoordinator = MainCoordinator()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = .init(frame: UIScreen.main.bounds)
        window!.rootViewController = mainCoordinator.navigationController
        window!.makeKeyAndVisible()
        mainCoordinator.start()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return [.all]
    }
}

