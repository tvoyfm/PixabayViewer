//
//  SceneDelegate.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: SearchCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // Получаем координатор из DI контейнера
        guard let coordinator = DIContainer.shared.resolve(type: SearchCoordinator.self) else {
            fatalError("SearchCoordinator не зарегистрирован в DI контейнере")
        }

        self.coordinator = coordinator

        // Устанавливаем окно для навигационного контроллера
        window?.rootViewController = coordinator.navigationController

        // Запускаем начальный флоу
        coordinator.start()

        window?.makeKeyAndVisible()
    }
}
