//
//  SearchVC.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Combine
import UIKit

final class SearchVC: UIViewController {
    // MARK: - Properties

    private let viewModel: SearchVM
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var searchTextField: SearchTextField = {
        let textField = SearchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.searchDelegate = self
        textField.placeholder = LocalizationKeys.Search.placeholder.localized
        return textField
    }()

    private lazy var searchCollectionView: SearchCollectionView = {
        let collectionView = SearchCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()

    // MARK: - Initialization

    init(viewModel: SearchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = LocalizationKeys.Search.title.localized
        view.backgroundColor = .systemBackground

        view.addSubview(searchTextField)
        view.addSubview(searchCollectionView)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),

            searchCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            searchCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - ViewModel Binding

    private func setupBindings() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }

    private func handleState(_ state: SearchState) {
        switch state {
        case .empty:
            handleEmptyState()
        case .loading(let isFirstPage):
            handleLoadingState(isFirstPage: isFirstPage)
        case .loaded(let isFirstPage):
            handleLoadedState(isFirstPage: isFirstPage)
        case .noResults:
            handleNoResultsState()
        case .error(let error):
            handleErrorState(error: error)
        }
    }
    
    // MARK: - Обработка состояний
    
    /// Обрабатывает пустое состояние (когда нет поискового запроса)
    private func handleEmptyState() {
        searchCollectionView.setImagePairs([])
        searchCollectionView.showMessage(LocalizationKeys.Search.emptyState.localized, type: .empty)
    }
    
    /// Обрабатывает состояние загрузки
    /// - Parameter isFirstPage: Флаг, указывающий на загрузку первой страницы
    private func handleLoadingState(isFirstPage: Bool) {
        searchCollectionView.hideMessage()
        
        if isFirstPage {
            searchCollectionView.startLoading()
            searchCollectionView.setImagePairs([])
        }
    }
    
    /// Обрабатывает состояние успешной загрузки
    /// - Parameter isFirstPage: Флаг, указывающий на загрузку первой страницы
    private func handleLoadedState(isFirstPage: Bool) {
        searchCollectionView.hideMessage()
        searchCollectionView.stopLoading()
        
        updateCollectionViewWithNewData(isFirstPage: isFirstPage)
    }
    
    /// Обновляет коллекцию новыми данными, либо полностью обновляя её, либо добавляя новые элементы
    /// - Parameter isFirstPage: Флаг, указывающий на загрузку первой страницы
    private func updateCollectionViewWithNewData(isFirstPage: Bool) {
        if isFirstPage {
            // Для первой страницы полностью обновляем коллекцию
            searchCollectionView.setImagePairs(viewModel.imageDataPairs)
        } else {
            // Для последующих страниц добавляем только новые элементы
            appendNewItemsToCollectionIfNeeded()
        }
    }
    
    /// Добавляет новые элементы в коллекцию, если их количество в ViewModel больше, чем в коллекции
    private func appendNewItemsToCollectionIfNeeded() {
        let existingCount = searchCollectionView.imagePairs.count
        let totalCount = viewModel.imageDataPairs.count
        
        if totalCount > existingCount {
            let newItems = Array(viewModel.imageDataPairs.suffix(totalCount - existingCount))
            searchCollectionView.appendImagePairs(newItems)
        }
    }
    
    /// Обрабатывает состояние отсутствия результатов поиска
    private func handleNoResultsState() {
        searchCollectionView.stopLoading()
        searchCollectionView.showMessage(LocalizationKeys.Search.noResults.localized, type: .info)
    }
    
    /// Обрабатывает состояние ошибки
    /// - Parameter error: Ошибка, которую нужно отобразить
    private func handleErrorState(error: SearchError) {
        searchCollectionView.stopLoading()
        searchCollectionView.showMessage(error.message, type: .error)
    }
}

// MARK: - SearchTextFieldDelegate

extension SearchVC: SearchTextFieldDelegate {
    /// Вызывается при обновлении текста в поисковом поле
    /// - Parameters:
    ///   - textField: Поисковое поле, в котором произошло обновление
    ///   - text: Новый текст поискового запроса
    func searchTextField(_ textField: SearchTextField, didUpdateSearchText text: String) {
        viewModel.updateSearchText(text)
    }
}

// MARK: - SearchCollectionViewDelegate

extension SearchVC: SearchCollectionViewDelegate {
    /// Вызывается при выборе элемента в коллекции
    /// - Parameters:
    ///   - collectionView: Коллекция, в которой произошел выбор
    ///   - indexPath: Индекс выбранного элемента
    ///   - isLeftImage: Флаг, указывающий на выбор обычного (true) или граффити (false) изображения
    func collectionView(_ collectionView: SearchCollectionView, didSelectItemAt indexPath: IndexPath, isLeftImage: Bool) {
        viewModel.showImagePreview(itemAt: indexPath, isLeftImage: isLeftImage)
    }

    /// Вызывается, когда пользователь прокрутил до конца коллекции и требуется загрузить больше данных
    /// - Parameter collectionView: Коллекция, в которой произошла прокрутка до конца
    func collectionViewDidReachEnd(_ collectionView: SearchCollectionView) {
        viewModel.loadMoreData()
    }
}
