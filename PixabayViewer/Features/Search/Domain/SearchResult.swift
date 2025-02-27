//
//  SearchApiResult.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Foundation

struct SearchResult {
    let total: Int
    let totalHits: Int
    let images: [PixabayImage]
}

struct PixabayImage {
    let id: Int
    let tags: String
    let webformatURL: URL
    let largeImageURL: URL

    var tagsList: [String] {
        return tags.components(separatedBy: ", ")
    }
}
