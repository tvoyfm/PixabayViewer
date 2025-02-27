import Foundation

/// Простой контейнер зависимостей для управления объектами в приложении
final class DIContainer {
    /// Синглтон для глобального доступа к контейнеру
    static let shared = DIContainer()

    /// Хранилище зарегистрированных фабрик
    private var factories: [String: Any] = [:]

    /// Хранилище синглтонов
    private var singletons: [String: Any] = [:]

    private init() {}

    /// Регистрирует фабрику для создания объектов
    /// - Parameters:
    ///   - type: Тип регистрируемого объекта
    ///   - factory: Замыкание, создающее экземпляр объекта
    func register<T>(type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    /// Регистрирует синглтон
    /// - Parameters:
    ///   - type: Тип регистрируемого синглтона
    ///   - factory: Замыкание, создающее экземпляр синглтона (вызывается только один раз)
    func registerSingleton<T>(type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        let instance = factory()
        singletons[key] = instance
    }

    /// Получает зарегистрированный экземпляр
    /// - Parameter type: Тип объекта для получения
    /// - Returns: Экземпляр запрошенного типа или nil, если тип не зарегистрирован
    func resolve<T>(type: T.Type) -> T? {
        let key = String(describing: type)

        // Сначала проверяем среди синглтонов
        if let instance = singletons[key] as? T {
            return instance
        }

        // Затем проверяем среди фабрик
        if let factory = factories[key] as? () -> T {
            return factory()
        }

        return nil
    }
}

/// Протокол для объектов, которые могут быть зарегистрированы в DI контейнере
protocol DIRegistrable {
    /// Регистрирует все зависимости объекта в контейнере
    static func registerDependencies(in container: DIContainer)
}
