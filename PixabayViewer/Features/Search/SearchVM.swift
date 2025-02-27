//
//  SearchVM.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Combine
import Foundation

/// ViewModel для экрана поиска изображений
/// Отвечает за управление поиском и предоставление данных для отображения в SearchVC
final class SearchVM {
    // MARK: - Properties

    private let coordinator: SearchCoordinator
    private let imageLoadingService: ImageLoadingServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers
    
    var state: PassthroughSubject<SearchState, Never> {
        return imageLoadingService.state
    }
    
    // MARK: - Public Properties
    
    var imageDataPairs: [ImageDataPair] {
        return convertToImageDataPairs(imageLoadingService.imagePairs)
    }
    
    // MARK: - Private Properties
    
    private var imagePairs: [ImagePair] {
        return imageLoadingService.imagePairs
    }

    // MARK: - Initialization

    /// Инициализирует ViewModel с указанным координатором
    /// - Parameter coordinator: Координатор, отвечающий за навигацию
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
        
        if let service = DIContainer.shared.resolve(type: ImageLoadingServiceProtocol.self) {
            self.imageLoadingService = service
        } else {
            fatalError("ImageLoadingServiceProtocol не зарегистрирован в DI контейнере")
        }
    }

    // MARK: - Public Methods

    /// Обновляет текст поиска, который будет использоваться для запроса изображений
    /// - Parameter text: Строка поиска, введенная пользователем
    func updateSearchText(_ text: String) {
        imageLoadingService.updateSearchText(text)
    }

    /// Загружает следующую порцию данных (используется при бесконечной прокрутке)
    func loadMoreData() {
        imageLoadingService.loadMoreData()
    }
    
    /// Отображает экран предпросмотра изображения
    /// - Parameters:
    ///   - indexPath: Индекс выбранного изображения в коллекции
    ///   - isLeftImage: Флаг, указывающий на выбор обычного (true) или граффити (false) изображения
    func showImagePreview(itemAt indexPath: IndexPath, isLeftImage: Bool) {
        guard indexPath.item < imagePairs.count else { return }
        
        let imagePair = imagePairs[indexPath.item]
        let selectedIndex = isLeftImage ? 0 : 1
        coordinator.showImagePreview(for: imagePair, selectedIndex: selectedIndex)
    }
    
    // MARK: - Private Methods
    
    /// Преобразует пары изображений из API в пары данных для UI
    /// - Parameter imagePairs: Массив оригинальных пар изображений
    /// - Returns: Массив пар данных изображений для UI
    private func convertToImageDataPairs(_ imagePairs: [ImagePair]) -> [ImageDataPair] {
        return imagePairs.map { pair in
            let leftImage = ImageData(
                tags: pair.regularImage.tags,
                thumbnailURL: pair.regularImage.webformatURL,
                fullSizeURL: pair.regularImage.largeImageURL
            )
            
            let rightImage: ImageData?
            if let graffitiImage = pair.graffitiImage {
                rightImage = ImageData(
                    tags: graffitiImage.tags,
                    thumbnailURL: graffitiImage.webformatURL,
                    fullSizeURL: graffitiImage.largeImageURL
                )
            } else {
                rightImage = nil
            }
            
            return ImageDataPair(leftImage: leftImage, rightImage: rightImage)
        }
    }
}
