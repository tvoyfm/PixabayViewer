//
//  SearchTextField.swift
//  PixabayViewer
//
//  Created by Глеб Столярчук on 27.02.2025.
//

import UIKit

protocol SearchTextFieldDelegate: AnyObject {
    func searchTextField(_ textField: SearchTextField, didUpdateSearchText text: String)
}

final class SearchTextField: UITextField {
    weak var searchDelegate: SearchTextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    private func setupTextField() {
        placeholder = "Введите поисковый запрос"
        borderStyle = .roundedRect
        returnKeyType = .search
        clearButtonMode = .whileEditing
        backgroundColor = .systemBackground
        autocorrectionType = .no
        autocapitalizationType = .none

        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func textFieldDidChange() {
        guard let text = text else { return }
        searchDelegate?.searchTextField(self, didUpdateSearchText: text)
    }
}
