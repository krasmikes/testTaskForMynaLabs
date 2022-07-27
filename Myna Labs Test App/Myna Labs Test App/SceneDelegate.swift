//
//  SceneDelegate.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let mainNavigationController = UINavigationController(rootViewController: MainViewController())
        mainNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)

        let searchNavigationController = UINavigationController(rootViewController: UIViewController())
        searchNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let profileNavigationController = UINavigationController(rootViewController: UIViewController())
        profileNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), tag: 2)

        let tabBarViewController = UITabBarController()
        tabBarViewController.viewControllers = [mainNavigationController, searchNavigationController, profileNavigationController]

        window.rootViewController = tabBarViewController
        window.makeKeyAndVisible()

        self.window = window
    }
}

