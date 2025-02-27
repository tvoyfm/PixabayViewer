//
//  ImagePreviewVC.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import Combine
import UIKit

final class ImagePreviewVC: UIViewController {
    // MARK: - Properties

    private let viewModel: ImagePreviewVM
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var tagsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var switchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Initialization

    init(viewModel: ImagePreviewVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        viewModel.loadCurrentImage()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .black

        view.addSubview(imageView)
        view.addSubview(tagsLabel)
        view.addSubview(closeButton)
        view.addSubview(switchButton)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: tagsLabel.topAnchor, constant: -20),

            tagsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tagsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tagsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            switchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            switchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            switchButton.widthAnchor.constraint(equalToConstant: 44),
            switchButton.heightAnchor.constraint(equalToConstant: 44),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Скрываем кнопку переключения, если нет второго изображения
        switchButton.isHidden = !viewModel.hasGraffitiImage

        // Обновляем теги
        tagsLabel.text = viewModel.currentTags

        // Добавляем жест смахивания для закрытия
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    private func setupBindings() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleImageState(state)
            }
            .store(in: &cancellables)
    }

    private func handleImageState(_ state: ImagePreviewState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()

        case let .loaded(image):
            loadingIndicator.stopAnimating()
            imageView.image = image
            tagsLabel.text = viewModel.currentTags

        case .failure:
            loadingIndicator.stopAnimating()
            imageView.image = UIImage(systemName: "exclamationmark.triangle")
        }
    }

    // MARK: - Actions

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func switchButtonTapped() {
        viewModel.switchImage()
    }

    @objc private func handleSwipe() {
        dismiss(animated: true)
    }
}
