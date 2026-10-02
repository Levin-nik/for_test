//
//  TIDRoundButton.swift
//  T-ID
//
//  Copyright (c) 2024 TBank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

final class TIDCompactButton: UIButton {

    /// Высота кнопки
    private var size: CGFloat { 56 }

    /// Изображение
    private var image: UIImage? {
        switch colorStyle {
        case .primary:
            Bundle.resourcesBundle?
                .imageNamed("logo-t-white")
        case .alternativeLight, .dark, .light:
            Bundle.resourcesBundle?
                .imageNamed("logo-t-yellow")
        }
    }

    private lazy var imageBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private let colorStyle: TIDButtonColorStyle

    override var isHighlighted: Bool {
        didSet {
            updateAppearanceForCurrentState()
        }
    }

    init(colorStyle: TIDButtonColorStyle) {
        self.colorStyle = colorStyle

        super.init(frame: .zero)

        didInitialize()
    }

    required init?(coder: NSCoder) {
        self.colorStyle = .primary

        super.init(coder: coder)
        didInitialize()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: size, height: size)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2

        let maxSide = max(bounds.width, bounds.height)
        if maxSide > size {
            updateInsets()
        }

        if case .light = colorStyle {
            self.layer.borderColor = colorStyle.borderColor.cgColor
            self.layer.borderWidth = 1
        }
    }

    // MARK: - Private

    private func didInitialize() {
        configure()
        updateAppearanceForCurrentState()
    }

    private func configure() {
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)

        // Image
        imageView?.contentMode = .scaleAspectFit
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill

        contentEdgeInsets = UIEdgeInsets(top: 18, left: 16, bottom: 14, right: 16)

        addSubview(imageBorder)
    }

    private func updateAppearanceForCurrentState() {
        backgroundColor = colorStyle.backgroundColorFor(state: state)
    }

    private func updateInsets() {
        contentEdgeInsets = UIEdgeInsets(
            top: bounds.height * 18 / size,
            left: bounds.width * 16 / size,
            bottom: bounds.height * 14 / size,
            right: bounds.width * 16 / size
        )
    }
}
