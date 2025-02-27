import Foundation
import Combine

protocol ImageLoadingServiceProtocol {
    var statePublisher: PassthroughSubject<SearchState, Never> { get }
    var imagePairs: [ImagePair] { get }
    var imageDataPairs: [ImageDataPair] { get }
    
    func updateSearchText(_ text: String)
    func loadMoreData()
    func performSearch(query: String)
}

final class ImageLoadingService: ImageLoadingServiceProtocol {
    // MARK: - Publishers
    
    let statePublisher = PassthroughSubject<SearchState, Never>()
    
    // MARK: - Properties
    
    private let searchProvider: SearchProvider
    
    // Свойства пагинации
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    private var isLoading: Bool = false
    
    private var searchTextSubject = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    private let debounceInterval: TimeInterval = 0.7
    
    private(set) var imagePairs: [ImagePair] = []
    private(set) var imageDataPairs: [ImageDataPair] = []
    
    // MARK: - Initialization
    
    init(searchProvider: SearchProvider = PixabaySearchProvider()) {
        self.searchProvider = searchProvider
        setupSearchTextDebounce()
        
        // Инициируем пустое состояние
        statePublisher.send(.empty)
    }
    
    // MARK: - Private Methods
    
    private func setupSearchTextDebounce() {
        searchTextSubject
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                // Выполняем синхронный поиск - так гарантируем, что при смене searchText всегда будет запрос
                self.performSearch(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Методы пагинации
    
    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        isLoading = false
    }
    
    private func nextPage() -> Int {
        currentPage += 1
        return currentPage
    }
    
    private func setHasMorePages(_ hasMore: Bool) {
        hasMorePages = hasMore
    }
    
    // MARK: - Public Methods
    
    func updateSearchText(_ text: String) {
        searchTextSubject.send(text)
    }
    
    func loadMoreData() {
        guard !isLoading && 
              hasMorePages && 
              !searchTextSubject.value.isEmpty else { return }
        
        let nextPage = nextPage()
        loadData(page: nextPage)
    }
    
    func performSearch(query: String) {
        // Сбрасываем пагинацию при новом поиске
        resetPagination()
        imagePairs = []
        imageDataPairs = []
        
        // Проверка пустого запроса
        if query.isEmpty {
            statePublisher.send(.empty)
            return
        }
        
        loadData(page: currentPage)
    }
    
    private func loadData(page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        statePublisher.send(.loading(isFirstPage: page == 1))
        
        Task {
            do {
                let newImagePairs = try await searchProvider.search(
                    query: searchTextSubject.value, 
                    page: page
                )
                
                await MainActor.run {
                    isLoading = false
                    
                    if newImagePairs.isEmpty {
                        setHasMorePages(false)
                        
                        if page == 1 {
                            statePublisher.send(.noResults)
                        } else {
                            statePublisher.send(.loaded(isFirstPage: false))
                        }
                    } else {
                        if page == 1 {
                            imagePairs = newImagePairs
                            imageDataPairs = convertToImageDataPairs(newImagePairs)
                        } else {
                            imagePairs.append(contentsOf: newImagePairs)
                            imageDataPairs.append(contentsOf: convertToImageDataPairs(newImagePairs))
                        }
                        
                        statePublisher.send(.loaded(isFirstPage: page == 1))
                    }
                }
            } catch let error as SearchError {
                await MainActor.run {
                    isLoading = false
                    statePublisher.send(.error(error))
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    statePublisher.send(.error(.unknown))
                }
            }
        }
    }
    
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