import UIKit

/// Класс для регистрации зависимостей приложения
final class DependencyRegistration {
    /// Регистрирует все зависимости приложения
    static func registerDependencies() {
        let container = DIContainer.shared

        // Регистрация сервисов
        registerServices(in: container)

        // Регистрация координаторов
        registerCoordinators(in: container)
    }

    /// Регистрирует сервисы
    private static func registerServices(in container: DIContainer) {
        // Синглтоны
        registerSingletons(in: container)

        // Регистрируем SearchService
        container.register(type: SearchService.self) {
            PixabaySearchService()
        }

        // Регистрируем SearchProvider, зависит от SearchService
        container.register(type: SearchProvider.self) {
            let searchService = container.resolve(type: SearchService.self)!
            return PixabaySearchProvider(searchService: searchService)
        }

        // Регистрируем ImageLoadingServiceProtocol, зависит от SearchProvider
        container.register(type: ImageLoadingServiceProtocol.self) {
            let searchProvider = container.resolve(type: SearchProvider.self)!
            return ImageLoadingService(searchProvider: searchProvider)
        }
    }

    /// Регистрирует синглтоны
    private static func registerSingletons(in container: DIContainer) {
        // Регистрируем ImageCache как синглтон
        container.registerSingleton(type: ImageCache.self) {
            ImageCache.shared
        }

        // Регистрируем ImageLoader как синглтон
        container.registerSingleton(type: ImageLoader.self) {
            ImageLoader.shared
        }
    }

    /// Регистрирует координаторы
    private static func registerCoordinators(in container: DIContainer) {
        // Фабрика для создания основного координатора
        container.register(type: SearchCoordinator.self) {
            let navigationController = UINavigationController()
            return PixabaySearchCoordinator(navigationController: navigationController)
        }
    }
}
