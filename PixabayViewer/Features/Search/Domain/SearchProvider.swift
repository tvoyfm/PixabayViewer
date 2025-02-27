//
//  SearchApiProvider.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

struct ImagePair {
    let regularImage: PixabayImage
    let graffitiImage: PixabayImage?
}

protocol SearchProvider {
    func search(query: String, page: Int) async throws -> [ImagePair]
}

final class PixabaySearchProvider: SearchProvider {
    private let searchService: SearchService
    private let imagesPerPage = 10

    init(searchService: SearchService) {
        self.searchService = searchService
    }

    func search(query: String, page: Int) async throws -> [ImagePair] {
        // Параллельный запуск запросов для улучшения производительности
        async let regularResultTask = searchService.search(query: query, page: page, perPage: imagesPerPage)
        async let graffitiResultTask = searchService.searchGraffiti(query: query, page: page, perPage: imagesPerPage)

        do {
            // Дожидаемся результатов обоих запросов
            let regularResult = try await regularResultTask
            let graffitiResult = try? await graffitiResultTask // Игнорируем ошибки граффити-запроса

            // Если у нас есть результаты и для обычного, и для граффити запроса
            if let graffitiResult = graffitiResult {
                return createImagePairs(regularImages: regularResult.images, graffitiImages: graffitiResult.images)
            } else {
                // Если запрос граффити не удался, показываем только обычные изображения
                return createImagePairs(regularImages: regularResult.images, graffitiImages: [])
            }
        } catch {
            // Проксируем ошибку основного запроса дальше
            throw error
        }
    }

    private func createImagePairs(regularImages: [PixabayImage], graffitiImages: [PixabayImage]) -> [ImagePair] {
        var imagePairs: [ImagePair] = []

        for (index, regularImage) in regularImages.enumerated() {
            let graffitiImage = index < graffitiImages.count ? graffitiImages[index] : nil
            let pair = ImagePair(regularImage: regularImage, graffitiImage: graffitiImage)
            imagePairs.append(pair)
        }

        return imagePairs
    }
}
