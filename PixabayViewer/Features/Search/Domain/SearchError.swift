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
            return LocalizationKeys.Errors.invalidQuery.localized
        case .networkError:
            return LocalizationKeys.Errors.networkError.localized
        case .serverError:
            return LocalizationKeys.Errors.serverError.localized
        case .noResults:
            return LocalizationKeys.Search.noResults.localized
        case .unknown:
            return LocalizationKeys.Errors.generalError.localized
        }
    }
}
