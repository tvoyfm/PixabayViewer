//
//  ImagePreviewVM.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Combine
import Foundation
import UIKit

final class ImagePreviewVM {
    // MARK: - Properties

    private let imagePair: ImagePair
    private var currentIndex: Int // 0 для обычного изображения, 1 для граффити
    private let imageLoader: ImageLoader

    let state = PassthroughSubject<ImagePreviewState, Never>()

    var hasGraffitiImage: Bool {
        return imagePair.graffitiImage != nil
    }

    var currentTags: String? {
        return currentIndex == 0 ? imagePair.regularImage.tags : imagePair.graffitiImage?.tags
    }

    var currentLargeImageURL: URL? {
        return currentIndex == 0 ? imagePair.regularImage.largeImageURL : imagePair.graffitiImage?.largeImageURL
    }

    // MARK: - Initialization

    init(imagePair: ImagePair, selectedIndex: Int) {
        self.imagePair = imagePair
        // Если выбрано граффити-изображение (индекс 1), но его нет, переключаемся на обычное (индекс 0)
        currentIndex = (selectedIndex == 1 && imagePair.graffitiImage == nil) ? 0 : selectedIndex

        // Получаем ImageLoader из DI или используем созданный по умолчанию
        if let loader = DIContainer.shared.resolve(type: ImageLoader.self) {
            imageLoader = loader
        } else {
            fatalError("ImageLoader не зарегистрирован в DI контейнере")
        }
    }

    // MARK: - Public Methods

    func loadCurrentImage() {
        guard let imageURL = currentLargeImageURL else {
            state.send(.failure)
            return
        }

        state.send(.loading)

        imageLoader.loadImage(from: imageURL) { [weak self] image in
            guard let self = self else { return }

            if let image = image {
                self.state.send(.loaded(image: image))
            } else {
                self.state.send(.failure)
            }
        }
    }

    func switchImage() {
        guard hasGraffitiImage else { return }

        currentIndex = currentIndex == 0 ? 1 : 0
        loadCurrentImage()
    }
}

// MARK: - ImagePreviewState Enum

enum ImagePreviewState {
    case loading
    case loaded(image: UIImage)
    case failure
}
