import UIKit

final class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Устанавливаем лимиты кеша
        cache.countLimit = 100 // Максимальное количество объектов
        cache.totalCostLimit = 50 * 1024 * 1024 // Примерно 50MB
        
        // Подписываемся на уведомление о том, что память заканчивается
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func saveImage(_ image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        cache.setObject(image, forKey: key)
    }
    
    func getImage(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString
        return cache.object(forKey: key)
    }
    
    @objc func clearCache() {
        cache.removeAllObjects()
    }
} 