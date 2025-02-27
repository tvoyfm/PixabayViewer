//
//  SearchApiService.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

protocol SearchApiService {
    func search(query: String, page: Int, perPage: Int) async throws -> SearchApiResult
}

final class PixabayApiService: SearchApiService {
    private let baseURL = "https://pixabay.com/api/"
    private let apiKey = "38738026-cb365c92113f40af7a864c24a"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func search(query: String, page: Int, perPage: Int) async throws -> SearchApiResult {
        guard var components = URLComponents(string: baseURL) else {
            throw SearchApiError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]

        guard let url = components.url else {
            throw SearchApiError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SearchApiError.unknown
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw SearchApiError.serverError(httpResponse.statusCode)
            }

            do {
                let result = try JSONDecoder().decode(SearchApiResult.self, from: data)
                return result
            } catch {
                throw SearchApiError.decodingError(error)
            }
        } catch let error as SearchApiError {
            throw error
        } catch {
            throw SearchApiError.networkError(error)
        }
    }
}
