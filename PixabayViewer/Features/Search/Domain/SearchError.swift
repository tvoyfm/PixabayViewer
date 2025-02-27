//
//  SearchApiError.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

enum SearchError: Error {
    case invalidQuery
    case networkError
    case serverError
    case noResults
    case unknown

    var message: String {
        switch self {
        case .invalidQuery:
            return "Некорректный запрос"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .serverError:
            return "Ошибка сервера. Попробуйте позже"
        case .noResults:
            return "Ничего не найдено по вашему запросу"
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }
}
