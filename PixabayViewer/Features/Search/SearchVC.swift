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
            searchCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - ViewModel Binding

    private func setupBindings() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }

    private func handleState(_ state: SearchState) {
        switch state {
        case .empty:
            searchCollectionView.setImagePairs([])
            searchCollectionView.showMessage(LocalizationKeys.Search.emptyState.localized, type: .empty)

        case .loading(let isFirstPage):
            searchCollectionView.hideMessage()
            if isFirstPage {
                searchCollectionView.startLoading()
                searchCollectionView.setImagePairs([])
            }

        case .loaded(let isFirstPage):
            searchCollectionView.hideMessage()
            searchCollectionView.stopLoading()

            if isFirstPage {
                searchCollectionView.setImagePairs(viewModel.imageDataPairs)
            } else if viewModel.imageDataPairs.count > searchCollectionView.imagePairs.count {
                let newItems = Array(viewModel.imageDataPairs.suffix(
                    viewModel.imageDataPairs.count - searchCollectionView.imagePairs.count
                ))
                searchCollectionView.appendImagePairs(newItems)
            }

        case .noResults:
            searchCollectionView.stopLoading()
            searchCollectionView.showMessage(LocalizationKeys.Search.noResults.localized, type: .info)

        case .error(let error):
            searchCollectionView.stopLoading()
            searchCollectionView.showMessage(error.message, type: .error)
        }
    }
}

// MARK: - SearchTextFieldDelegate

extension SearchVC: SearchTextFieldDelegate {
    func searchTextField(_ textField: SearchTextField, didUpdateSearchText text: String) {
        viewModel.updateSearchText(text)
    }
}

// MARK: - SearchCollectionViewDelegate

extension SearchVC: SearchCollectionViewDelegate {
    func collectionView(_ collectionView: SearchCollectionView, didSelectItemAt indexPath: IndexPath, isLeftImage: Bool) {
        viewModel.showImagePreview(itemAt: indexPath, isLeftImage: isLeftImage)
    }

    func collectionViewDidReachEnd(_ collectionView: SearchCollectionView) {
        viewModel.loadMoreData()
    }
}
