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
        // Регистрируем ImageCache как синглтон
        container.registerSingleton(type: ImageCache.self) {
            return ImageCache.shared
        }
        
        // Регистрируем ImageLoader как синглтон
        container.registerSingleton(type: ImageLoader.self) {
            return ImageLoader.shared
        }
        
        // Регистрируем SearchProvider
        container.register(type: SearchProvider.self) {
            return PixabaySearchProvider()
        }
        
        // Регистрируем ImageLoadingServiceProtocol
        container.register(type: ImageLoadingServiceProtocol.self) {
            let searchProvider = container.resolve(type: SearchProvider.self)!
            return ImageLoadingService(searchProvider: searchProvider)
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