//
//  SearchCollectionViewCell.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

protocol SearchCollectionViewCellDelegate: AnyObject {
    func cellDidTapImage(_ cell: SearchCollectionViewCell, isLeftImage: Bool)
}

final class SearchCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchCollectionViewCell"

    weak var delegate: SearchCollectionViewCellDelegate?

    // Левое изображение
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftImageTapped))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }()

    private lazy var leftTagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Правое изображение
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageTapped))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }()

    private lazy var rightTagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Текущие URL для загрузки
    private var leftImageURL: URL?
    private var rightImageURL: URL?

    // Индикаторы загрузки
    private lazy var leftLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var rightLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        leftImageView.image = nil
        rightImageView.image = nil
        leftTagsLabel.text = nil
        rightTagsLabel.text = nil
        leftImageURL = nil
        rightImageURL = nil
        leftLoadingIndicator.stopAnimating()
        rightLoadingIndicator.stopAnimating()
    }

    private func setupViews() {
        contentView.backgroundColor = .systemBackground

        // Добавляем левое изображение и его теги
        contentView.addSubview(leftImageView)
        contentView.addSubview(leftTagsLabel)
        contentView.addSubview(leftLoadingIndicator)

        // Добавляем правое изображение и его теги
        contentView.addSubview(rightImageView)
        contentView.addSubview(rightTagsLabel)
        contentView.addSubview(rightLoadingIndicator)

        NSLayoutConstraint.activate([
            // Левое изображение
            leftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            leftImageView.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -4),
            leftImageView.heightAnchor.constraint(equalToConstant: 150),

            leftLoadingIndicator.centerXAnchor.constraint(equalTo: leftImageView.centerXAnchor),
            leftLoadingIndicator.centerYAnchor.constraint(equalTo: leftImageView.centerYAnchor),

            leftTagsLabel.topAnchor.constraint(equalTo: leftImageView.bottomAnchor, constant: 4),
            leftTagsLabel.leadingAnchor.constraint(equalTo: leftImageView.leadingAnchor),
            leftTagsLabel.trailingAnchor.constraint(equalTo: leftImageView.trailingAnchor),

            // Правое изображение
            rightImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rightImageView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 4),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightImageView.heightAnchor.constraint(equalToConstant: 150),

            rightLoadingIndicator.centerXAnchor.constraint(equalTo: rightImageView.centerXAnchor),
            rightLoadingIndicator.centerYAnchor.constraint(equalTo: rightImageView.centerYAnchor),

            rightTagsLabel.topAnchor.constraint(equalTo: rightImageView.bottomAnchor, constant: 4),
            rightTagsLabel.leadingAnchor.constraint(equalTo: rightImageView.leadingAnchor),
            rightTagsLabel.trailingAnchor.constraint(equalTo: rightImageView.trailingAnchor),
            rightTagsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    func configure(leftImage: ImageData?, rightImage: ImageData?) {
        // Настройка левого изображения
        if let leftImage = leftImage {
            leftImageView.isHidden = false
            leftTagsLabel.isHidden = false
            leftTagsLabel.text = leftImage.tags
            ImageLoader.shared.loadImage(
                from: leftImage.thumbnailURL,
                into: leftImageView,
                with: leftLoadingIndicator
            )
            leftImageURL = leftImage.thumbnailURL
        } else {
            leftImageView.isHidden = true
            leftTagsLabel.isHidden = true
        }

        // Настройка правого изображения
        if let rightImage = rightImage {
            rightImageView.isHidden = false
            rightTagsLabel.isHidden = false
            rightTagsLabel.text = rightImage.tags
            ImageLoader.shared.loadImage(
                from: rightImage.thumbnailURL,
                into: rightImageView,
                with: rightLoadingIndicator
            )
            rightImageURL = rightImage.thumbnailURL
        } else {
            rightImageView.isHidden = true
            rightTagsLabel.isHidden = true
        }
    }

    @objc private func leftImageTapped() {
        delegate?.cellDidTapImage(self, isLeftImage: true)
    }

    @objc private func rightImageTapped() {
        delegate?.cellDidTapImage(self, isLeftImage: false)
    }
}
