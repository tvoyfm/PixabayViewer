import UIKit

enum MessageType {
    case info
    case error
    case empty
}

final class MessageView: UIView {
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGray
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        addSubview(iconImageView)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        isHidden = true
    }

    func show(message: String, type: MessageType) {
        messageLabel.text = message

        switch type {
        case .info:
            iconImageView.image = UIImage(systemName: "info.circle")
        case .error:
            iconImageView.image = UIImage(systemName: "exclamationmark.triangle")
        case .empty:
            iconImageView.image = UIImage(systemName: "magnifyingglass")
        }

        isHidden = false
    }

    func hide() {
        isHidden = true
    }
}
