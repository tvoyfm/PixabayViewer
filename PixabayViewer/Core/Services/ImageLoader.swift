import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let imageCache = ImageCache.shared
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        session = URLSession(configuration: config)
    }

    /// Загружает изображение с указанного URL, используя кеш.
    /// - Parameters:
    ///   - url: URL изображения для загрузки
    ///   - completion: Замыкание, вызываемое после завершения (в главном потоке)
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Сначала проверяем кеш
        if let cachedImage = imageCache.getImage(for: url) {
            completion(cachedImage)
            return
        }

        // Загружаем изображение, если его нет в кеше
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // Сохраняем в кеш
            self.imageCache.saveImage(image, for: url)

            // Возвращаем результат в главном потоке
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }

    /// Загружает изображение с указанного URL, отображая индикатор загрузки
    /// - Parameters:
    ///   - url: URL изображения для загрузки
    ///   - imageView: UIImageView для отображения результата
    ///   - indicator: Опциональный индикатор загрузки
    ///   - placeholder: Опциональное изображение-заглушка при ошибке
    func loadImage(
        from url: URL,
        into imageView: UIImageView,
        with indicator: UIActivityIndicatorView? = nil,
        placeholder: UIImage? = UIImage(systemName: "photo")
    ) {
        indicator?.startAnimating()

        loadImage(from: url) { image in
            indicator?.stopAnimating()
            imageView.image = image ?? placeholder
        }
    }
}
