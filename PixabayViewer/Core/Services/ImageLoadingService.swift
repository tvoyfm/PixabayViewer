import Combine
import Foundation

/// Протокол сервиса загрузки изображений
protocol ImageLoadingServiceProtocol {
    /// Издатель состояния поиска
    var state: PassthroughSubject<SearchState, Never> { get }
    
    /// Текущие загруженные пары изображений
    var imagePairs: [ImagePair] { get }
    
    /// Обновляет поисковый текст
    func updateSearchText(_ text: String)
    
    /// Загружает дополнительные данные (следующую страницу)
    func loadMoreData()
}

final class ImageLoadingService: ImageLoadingServiceProtocol {
    // MARK: - Publishers

    let state = PassthroughSubject<SearchState, Never>()

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

    // MARK: - Initialization

    init(searchProvider: SearchProvider) {
        self.searchProvider = searchProvider
        setupSearchTextDebounce()

        // Инициируем пустое состояние
        state.send(.empty)
    }

    // MARK: - Private Methods

    private func setupSearchTextDebounce() {
        searchTextSubject
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
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

    private func performSearch(query: String) {
        // Сбрасываем пагинацию при новом поиске
        resetPagination()
        imagePairs = []

        // Проверка пустого запроса
        if query.isEmpty {
            state.send(.empty)
            return
        }

        loadData(page: currentPage)
    }

    private func loadData(page: Int) {
        guard !isLoading else { return }

        isLoading = true
        state.send(.loading(isFirstPage: page == 1))

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
                            state.send(.noResults)
                        } else {
                            state.send(.loaded(isFirstPage: false))
                        }
                    } else {
                        if page == 1 {
                            imagePairs = newImagePairs
                        } else {
                            imagePairs.append(contentsOf: newImagePairs)
                        }

                        state.send(.loaded(isFirstPage: page == 1))
                    }
                }
            } catch let error as SearchError {
                await MainActor.run {
                    isLoading = false
                    state.send(.error(error))
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    state.send(.error(.unknown))
                }
            }
        }
    }
}
