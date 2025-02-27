import Foundation

/// Перечисление с ключами локализации для типобезопасного доступа к строкам
enum LocalizationKeys {
    // MARK: - Общие строки
    enum Common {
        static let ok = "common.ok"
        static let cancel = "common.cancel"
        static let error = "common.error"
        static let retry = "common.retry"
        static let loading = "common.loading"
    }
    
    // MARK: - Экран поиска
    enum Search {
        static let title = "search.title"
        static let placeholder = "search.placeholder"
        static let emptyState = "search.empty_state"
        static let noResults = "search.no_results"
    }
    
    // MARK: - Экран предпросмотра изображения
    enum ImagePreview {
        static let title = "image_preview.title"
        static let imageInfo = "image_preview.image_info"
        static let tags = "image_preview.tags"
    }
    
    // MARK: - Ошибки
    enum Errors {
        static let networkError = "errors.network_error"
        static let serverError = "errors.server_error"
        static let generalError = "errors.general_error"
        static let imageLoadError = "errors.image_load_error"
        static let invalidQuery = "errors.invalid_query"
    }
} 