import Foundation

// Состояния процесса поиска
enum SearchState {
    case empty
    case loading(isFirstPage: Bool)
    case loaded(isFirstPage: Bool)
    case noResults
    case error(SearchError)
} 
