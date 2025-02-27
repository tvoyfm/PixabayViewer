//
//  SearchCollectionView.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

/// Протокол делегата для коллекции результатов поиска
/// Определяет методы для обработки выбора элементов и достижения конца прокрутки
protocol SearchCollectionViewDelegate: AnyObject {
    /// Вызывается при выборе элемента в коллекции
    /// - Parameters:
    ///   - collectionView: Коллекция, в которой произошел выбор
    ///   - indexPath: Индекс выбранного элемента
    ///   - isLeftImage: Флаг, указывающий на выбор левого (true) или правого (false) изображения
    func collectionView(
        _ collectionView: SearchCollectionView,
        didSelectItemAt indexPath: IndexPath,
        isLeftImage: Bool
    )

    /// Вызывается, когда пользователь достиг конца прокрутки коллекции
    /// - Parameter collectionView: Коллекция, в которой произошла прокрутка до конца
    func collectionViewDidReachEnd(
        _ collectionView: SearchCollectionView
    )
}

/// Секция коллекции поиска изображений
enum SearchCollectionSection {
    case main
}

/// Настраиваемая коллекция для отображения результатов поиска
final class SearchCollectionView: UIView {
    // MARK: - Properties

    weak var delegate: SearchCollectionViewDelegate?

    private(set) var imagePairs: [ImageDataPair] = []

    private let cellHeight: CGFloat = 200

    private var dataSource: UICollectionViewDiffableDataSource<SearchCollectionSection, ImageDataPair>!

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var messageView: MessageView = {
        let view = MessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureDataSource()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        configureDataSource()
    }

    // MARK: - Setup

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(cellHeight)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 8, bottom: 4, trailing: 8
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(cellHeight)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .vertical

        return UICollectionViewCompositionalLayout(
            section: section,
            configuration: layoutConfig
        )
    }

    private func setupViews() {
        backgroundColor = .systemBackground

        addSubview(collectionView)
        addSubview(loadingIndicator)
        addSubview(messageView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            messageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SearchCollectionSection, ImageDataPair>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, imagePair in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? SearchCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.delegate = self
            cell.configure(leftImage: imagePair.leftImage, rightImage: imagePair.rightImage)

            return cell
        }
    }

    // MARK: - Public Methods

    /// Устанавливает новые пары изображений для отображения с анимацией
    /// - Parameter imagePairs: Массив пар изображений
    func setImagePairs(_ imagePairs: [ImageDataPair]) {
        self.imagePairs = imagePairs
        messageView.hide()
        applySnapshot(animatingDifferences: true)
    }

    /// Добавляет новые пары изображений к существующим с анимацией
    /// - Parameter newImagePairs: Массив новых пар изображений
    func appendImagePairs(_ newImagePairs: [ImageDataPair]) {
        let oldCount = imagePairs.count
        imagePairs.append(contentsOf: newImagePairs)

        // Применяем измененный снэпшот с анимацией появления новых элементов
        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([.main])
            snapshot.appendItems(imagePairs)
        } else {
            let newItems = Array(imagePairs.suffix(from: oldCount))
            snapshot.appendItems(newItems)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    /// Отображает сообщение указанного типа
    /// - Parameters:
    ///   - message: Текст сообщения
    ///   - type: Тип сообщения (ошибка, информация и т.д.)
    func showMessage(_ message: String, type: MessageType) {
        messageView.show(message: message, type: type)
    }

    /// Скрывает сообщение
    func hideMessage() {
        messageView.hide()
    }

    /// Запускает индикатор загрузки
    func startLoading() {
        loadingIndicator.startAnimating()
    }

    /// Останавливает индикатор загрузки
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }

    /// Прокручивает коллекцию к первому элементу
    func scrollToTop() {
        if !imagePairs.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }

    // MARK: - Private Methods

    /// Применяет снимок текущего состояния данных к коллекции
    /// - Parameter animatingDifferences: Флаг, указывающий, нужно ли анимировать изменения
    private func applySnapshot(animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchCollectionSection, ImageDataPair>()
        snapshot.appendSections([.main])
        snapshot.appendItems(imagePairs)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate

extension SearchCollectionView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height

        // Когда пользователь прокрутил до конца с запасом в 100 пикселей
        if offsetY > contentHeight - scrollViewHeight - 100 && !loadingIndicator.isAnimating && !imagePairs.isEmpty {
            delegate?.collectionViewDidReachEnd(self)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: cellHeight)
    }
}

// MARK: - SearchCollectionViewCellDelegate

extension SearchCollectionView: SearchCollectionViewCellDelegate {
    func cellDidTapImage(_ cell: SearchCollectionViewCell, isLeftImage: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        delegate?.collectionView(self, didSelectItemAt: indexPath, isLeftImage: isLeftImage)
    }
}
