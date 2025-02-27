import Foundation

/// Структура для абстрактных данных изображения
/// Используется для отображения информации об изображении в пользовательском интерфейсе
struct ImageData: Hashable {
    /// Теги изображения
    let tags: String
    /// URL миниатюры изображения
    let thumbnailURL: URL
    /// URL полноразмерного изображения
    let fullSizeURL: URL
    
    /// Реализация Hashable для уникальной идентификации объекта
    func hash(into hasher: inout Hasher) {
        hasher.combine(thumbnailURL)
        hasher.combine(fullSizeURL)
    }
    
    /// Сравнение двух объектов ImageData
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.thumbnailURL == rhs.thumbnailURL && 
               lhs.fullSizeURL == rhs.fullSizeURL
    }
}
