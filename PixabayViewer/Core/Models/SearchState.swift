import Foundation

// Состояния процесса поиска
enum SearchState {
    case empty        // Пустое состояние, когда нет поискового запроса
    case loading(isFirstPage: Bool)
    case loaded(isFirstPage: Bool)
    case noResults
    case error(SearchError)
} 