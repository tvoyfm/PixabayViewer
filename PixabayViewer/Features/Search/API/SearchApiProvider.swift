//
//  SearchApiProvider.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

protocol SearchApiProvider {
    func search(query: String, page: Int, perPage: Int) async throws -> SearchApiResult
    func searchGraffiti(query: String, page: Int, perPage: Int) async throws -> SearchApiResult
}

final class PixabayApiProvider: SearchApiProvider {
    private let apiService: SearchApiService

    init(apiService: SearchApiService) {
        self.apiService = apiService
    }

    func search(query: String, page: Int, perPage: Int) async throws -> SearchApiResult {
        return try await apiService.search(query: query, page: page, perPage: perPage)
    }

    func searchGraffiti(query: String, page: Int, perPage: Int) async throws -> SearchApiResult {
        let graffitiQuery = "\(query) graffiti"
        return try await apiService.search(query: graffitiQuery, page: page, perPage: perPage)
    }
}
