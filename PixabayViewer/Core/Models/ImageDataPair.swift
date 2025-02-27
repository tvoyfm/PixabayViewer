import Foundation

/// Структура для пары изображений
/// Используется для хранения обычного и граффити изображений в одной ячейке
struct ImageDataPair: Hashable {
    /// Левое изображение (обычное)
    let leftImage: ImageData
    /// Правое изображение, может быть nil
    let rightImage: ImageData?
    
    /// Реализация Hashable для уникальной идентификации объекта
    func hash(into hasher: inout Hasher) {
        hasher.combine(leftImage)
        hasher.combine(rightImage)
    }
    
    /// Сравнение двух объектов ImageDataPair
    static func == (lhs: ImageDataPair, rhs: ImageDataPair) -> Bool {
        return lhs.leftImage == rhs.leftImage && 
               lhs.rightImage == rhs.rightImage
    }
}
