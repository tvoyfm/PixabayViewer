//
//  SearchApiService.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

protocol SearchService {
    func search(query: String, page: Int, perPage: Int) async throws -> SearchResult
    func searchGraffiti(query: String, page: Int, perPage: Int) async throws -> SearchResult
}

final class PixabaySearchService: SearchService {
    private let apiProvider: SearchApiProvider

    init(apiProvider: SearchApiProvider) {
        self.apiProvider = apiProvider
    }

    func search(query: String, page: Int, perPage: Int) async throws -> SearchResult {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SearchError.invalidQuery
        }

        do {
            let apiResult = try await apiProvider.search(query: query, page: page, perPage: perPage)
            return try mapApiResultToSearchResult(apiResult)
        } catch let error as SearchApiError {
            throw mapApiErrorToDomainError(error)
        }
    }

    func searchGraffiti(query: String, page: Int, perPage: Int) async throws -> SearchResult {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SearchError.invalidQuery
        }

        do {
            let apiResult = try await apiProvider.searchGraffiti(query: query, page: page, perPage: perPage)
            return try mapApiResultToSearchResult(apiResult)
        } catch let error as SearchApiError {
            throw mapApiErrorToDomainError(error)
        }
    }

    private func mapApiResultToSearchResult(_ apiResult: SearchApiResult) throws -> SearchResult {
        if apiResult.hits.isEmpty {
            throw SearchError.noResults
        }

        let images = apiResult.hits.compactMap { hit -> PixabayImage? in
            guard let webformatURL = URL(string: hit.webformatURL),
                  let largeImageURL = URL(string: hit.largeImageURL)
            else {
                return nil
            }

            return PixabayImage(
                id: hit.id,
                tags: hit.tags,
                webformatURL: webformatURL,
                largeImageURL: largeImageURL
            )
        }

        return SearchResult(
            total: apiResult.total,
            totalHits: apiResult.totalHits,
            images: images
        )
    }

    private func mapApiErrorToDomainError(_ error: SearchApiError) -> SearchError {
        switch error {
        case .invalidURL:
            return .invalidQuery
        case .networkError:
            return .networkError
        case .serverError:
            return .serverError
        case .decodingError, .unknown:
            return .unknown
        }
    }
}
