import Foundation

// Структура для абстрактных данных изображения
struct ImageData {
    let tags: String
    let thumbnailURL: URL
    let fullSizeURL: URL
}

// Структура для пары изображений
struct ImageDataPair {
    let leftImage: ImageData
    let rightImage: ImageData?
} 