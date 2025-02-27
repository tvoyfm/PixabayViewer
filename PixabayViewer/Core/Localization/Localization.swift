import Foundation

/// Класс для управления локализацией в приложении
final class Localization {
    /// Синглтон для глобального доступа к локализации
    static let shared = Localization()

    private init() {}

    /// Получает локализованную строку по ключу
    /// - Parameters:
    ///   - key: Ключ для локализации
    ///   - defaultValue: Значение по умолчанию, если ключ не найден
    ///   - comment: Комментарий для переводчиков
    /// - Returns: Локализованная строка
    func localized(_ key: String, defaultValue: String? = nil, comment: String = "") -> String {
        return NSLocalizedString(key, value: defaultValue ?? key, comment: comment)
    }
}

/// Расширение String для упрощения локализации
extension String {
    /// Возвращает локализованную версию строки
    var localized: String {
        return Localization.shared.localized(self)
    }

    /// Локализует строку с заданными аргументами
    /// - Parameter arguments: Аргументы для форматирования строки
    /// - Returns: Локализованная и отформатированная строка
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = localized
        return String(format: localizedString, arguments: arguments)
    }
}
