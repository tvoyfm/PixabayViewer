//
//  SceneDelegate.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let startVC = SearchVC()
        window?.rootViewController = UINavigationController(rootViewController: startVC)
        window?.makeKeyAndVisible()
    }
}
