//
//  SearchCollectionView.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

protocol SearchCollectionViewDelegate: AnyObject {
    func collectionView(_ collectionView: SearchCollectionView, didSelectItemAt indexPath: IndexPath, isLeftImage: Bool)
    func collectionViewDidReachEnd(_ collectionView: SearchCollectionView)
}

final class SearchCollectionView: UIView {
    weak var delegate: SearchCollectionViewDelegate?

    var imagePairs: [ImageDataPair] = []
    private let cellHeight: CGFloat = 200

    // Коллекция
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    // Индикатор загрузки внизу коллекции
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // Компонент для сообщений
    private lazy var messageView: MessageView = {
        let view = MessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
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
            messageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: - Public Methods

    func setImagePairs(_ imagePairs: [ImageDataPair]) {
        self.imagePairs = imagePairs
        messageView.hide()
        collectionView.reloadData()
    }

    func appendImagePairs(_ newImagePairs: [ImageDataPair]) {
        let startIndex = imagePairs.count
        imagePairs.append(contentsOf: newImagePairs)

        let indexPaths = (startIndex ..< imagePairs.count).map { IndexPath(item: $0, section: 0) }
        collectionView.insertItems(at: indexPaths)
    }

    func showMessage(_ message: String, type: MessageType) {
        messageView.show(message: message, type: type)
    }
    
    func hideMessage() {
        messageView.hide()
    }

    func startLoading() {
        loadingIndicator.startAnimating()
    }

    func stopLoading() {
        loadingIndicator.stopAnimating()
    }

    func scrollToTop() {
        if !imagePairs.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SearchCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePairs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier, for: indexPath) as? SearchCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.delegate = self
        let imagePair = imagePairs[indexPath.item]
        cell.configure(leftImage: imagePair.leftImage, rightImage: imagePair.rightImage)

        return cell
    }

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
