//
//  SearchVM.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Combine
import Foundation

final class SearchVM {
    // MARK: - Properties

    private let coordinator: SearchCoordinator
    private let imageLoadingService: ImageLoadingServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    // Publishers
    var statePublisher: PassthroughSubject<SearchState, Never> {
        return imageLoadingService.statePublisher
    }

    var imagePairs: [ImagePair] {
        return imageLoadingService.imagePairs
    }

    var imageDataPairs: [ImageDataPair] {
        return imageLoadingService.imageDataPairs
    }

    // MARK: - Initialization

    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator

        // Используем DI контейнер для получения сервиса или вызываем краш
        if let service = DIContainer.shared.resolve(type: ImageLoadingServiceProtocol.self) {
            imageLoadingService = service
        } else {
            fatalError("ImageLoadingServiceProtocol не зарегистрирован в DI контейнере")
        }
    }

    // MARK: - Public Methods

    func updateSearchText(_ text: String) {
        imageLoadingService.updateSearchText(text)
    }

    func loadMoreData() {
        imageLoadingService.loadMoreData()
    }

    func showImagePreview(itemAt indexPath: IndexPath, isLeftImage: Bool) {
        guard indexPath.item < imagePairs.count else { return }

        let imagePair = imagePairs[indexPath.item]
        let selectedIndex = isLeftImage ? 0 : 1
        coordinator.showImagePreview(for: imagePair, selectedIndex: selectedIndex)
    }
}
