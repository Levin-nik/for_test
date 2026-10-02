//
//  TIDButton.swift
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

final class TIDButton: UIButton {

    // MARK: Private properties

    private var titleString: String = ""
    private var badgeStyle: BadgeStyle?

    // MARK: Configuration

    private var config: TIDButtonConfiguration
    private var size: TIDButtonSize
    private var cachedSize: CGSize = .zero
    private var needsOutterBorder: Bool {
        config.style == .dark && size != .small
    }

    // MARK: UI views

    private lazy var badgeView = UIView(frame: .zero)
    private lazy var badgeLabel = UILabel(frame: .zero)
    private lazy var imageBorder = UIView(frame: .zero)

    // MARK: Internal properties

    override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    override var intrinsicContentSize: CGSize {
        guard badgeStyle != nil else {
            return .init(width: super.intrinsicContentSize.width, height: size.height)
        }

        let badgeWidth = badgeView.frame.width
            + size.imageWithBadgeLeadingOffset

        return .init(
            width: super.intrinsicContentSize.width + badgeWidth,
            height: size.height
        )
    }

    // MARK: Initializers

    init(
        configuration: TIDButtonConfiguration,
        titleString: String? = nil,
        badgeStyle: BadgeStyle? = nil
    ) {
        self.config = configuration
        self.size = configuration.size
        super.init(frame: .zero)
        self.titleString = titleString ?? ""
        self.badgeStyle = badgeStyle
        setupView()
    }

    required init?(coder: NSCoder) {
        self.config = .init()
        self.size = .medium
        super.init(coder: coder)
        setTitle(TIDButtonConstants.defaultTitle, for: .normal)
        self.titleString = TIDButtonConstants.defaultTitle
        self.badgeStyle = .none
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size.height != .zero else { return }
        cachedSize = bounds.size
        size = TIDButtonSize(height: bounds.height)
        layout()
    }

    private func updateAppearance() {
        backgroundColor = config.style.backgroundColorFor(state: state)
    }
}

// MARK: - Layout

extension TIDButton {

    private func setupView() {
        setContentHuggingPriority(.required, for: .vertical)
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        layer.cornerRadius = config.cornerRadius
        layer.borderColor = config.style.borderColor.cgColor

        setupTitle(titleString.isEmpty ? TIDButtonConstants.defaultTitle : titleString)
        redrawTitle()
        imageView?.contentMode = .scaleAspectFit

        if let badgeStyle = badgeStyle {
            badgeView.backgroundColor = config.style.badgeBackgroundColor
            badgeView.isUserInteractionEnabled = false
            addSubview(badgeView)

            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 2

            switch badgeStyle {
            case let .empty(value):
                badgeLabel.text = "\(numberFormatter.string(for: value) ?? "")% кэшбэк"
            case let .until(value):
                badgeLabel.text = "до \(numberFormatter.string(for: value) ?? "")% кэшбэка"
            }
            badgeLabel.font = .systemFont(ofSize: size.badgeFontSize)
            badgeLabel.textColor = config.style.badgeTextColor
            badgeLabel.sizeToFit()
            badgeLabel.isUserInteractionEnabled = false
            addSubview(badgeLabel)
        }

        insertSubview(imageBorder, belowSubview: imageView!)
        imageBorder.backgroundColor = .clear
        imageBorder.layer.borderWidth = size.imageBorderWidth
        imageBorder.layer.borderColor = config.style.imageBorderColor.cgColor
        imageBorder.isUserInteractionEnabled = false

        bringSubviewToFront(titleLabel!)
        bringSubviewToFront(imageView!)

        updateAppearance()
    }

    private func layout() {
        contentEdgeInsets = size.contentInsets
        layer.borderWidth = size.buttonBorderSize

        redrawTitle()
        redrawImage()

        if badgeStyle != nil {
            layoutWithBadge()
        } else {
            layoutWithoutBadge()
        }
    }

    func layoutWithBadge() {
        badgeLabel.font = .systemFont(ofSize: size.badgeFontSize)
        badgeLabel.sizeToFit()

        let titleTextRect = titleLabel!.textRect(
            forBounds: .init(origin: .zero, size: UIView.layoutFittingExpandedSize),
            limitedToNumberOfLines: 0
        )
        let badgeTextRect = badgeLabel.textRect(
            forBounds: .init(origin: .zero, size: UIView.layoutFittingExpandedSize),
            limitedToNumberOfLines: 0
        )

        let imageWidth = size.imageSize.width
        let titleWidth = titleTextRect.width

        let badgeWidth = size.badgeInsets.left
            + imageWidth
            + size.badgeLogoOffset * 2
            + badgeTextRect.size.width
            + size.badgeInsets.right

        let badgeHeight = size.imageSize.height
            + size.badgeLogoOffset * 2

        let badgePoint = CGPoint(
            x: imageView!.frame.minX
                - size.badgeLogoOffset
                - size.badgeInsets.left,
            y: imageView!.frame.midY - badgeHeight / 2
        )

        let badgeLabelPoint = CGPoint(
            x: badgePoint.x
                + size.badgeInsets.left
                + size.imageSize.width
                + size.badgeLogoOffset * 2,
            y: badgePoint.y + (badgeHeight - badgeTextRect.height) / 2
        )

        let badgeAdvancedSize = -size.imageWithBadgeLeadingOffset
            + size.badgeLogoOffset
            + badgeTextRect.size.width
            + size.badgeInsets.right

        imageEdgeInsets = UIEdgeInsets(
            top: .zero,
            left: (titleWidth + size.imageWithBadgeLeadingOffset) - badgeAdvancedSize / 2,
            bottom: .zero,
            right: -(titleWidth - size.imageWithBadgeLeadingOffset) + badgeAdvancedSize / 2
        )
        titleEdgeInsets = UIEdgeInsets(
            top: .zero,
            left: (-imageWidth - size.imageWithBadgeLeadingOffset) - badgeAdvancedSize / 2,
            bottom: .zero,
            right: (imageWidth + size.imageWithBadgeLeadingOffset) + badgeAdvancedSize / 2
        )

        badgeView.frame = .init(
            origin: badgePoint,
            size: .init(
                width: badgeWidth,
                height: badgeHeight
            )
        )
        badgeView.layer.cornerRadius = badgeHeight / 2

        badgeLabel.frame = .init(origin: badgeLabelPoint, size: badgeTextRect.size)
    }

    private func layoutWithoutBadge() {
        let titleTextRect = titleLabel!.textRect(
            forBounds: .init(origin: .zero, size: UIView.layoutFittingExpandedSize),
            limitedToNumberOfLines: 0
        )
        let imageWidth = size.imageSize.width
        let titleWidth = titleTextRect.width

        imageEdgeInsets = UIEdgeInsets(
            top: .zero,
            left: titleWidth + size.imageLeadingOffset / 2,
            bottom: .zero,
            right: -titleWidth - size.imageLeadingOffset / 2
        )
        titleEdgeInsets = UIEdgeInsets(
            top: .zero,
            left: -imageWidth - size.imageLeadingOffset / 2,
            bottom: .zero,
            right: imageWidth + size.imageLeadingOffset / 2
        )
    }

    private func setupTitle(_ string: String) {
        setTitle(string, for: .normal)
        setTitle(string, for: .highlighted)
        setTitleColor(config.style.titleColor, for: .normal)
        setTitleColor(config.style.titleColor, for: .highlighted)
    }

    private func redrawTitle() {
        titleLabel?.font = config.font.createBoldFont().withSize(size.titleFontSize)
        titleLabel?.sizeToFit()
    }

    private func redrawImage() {
        setImage(size.image, for: .normal)
        setImage(size.image, for: .highlighted)
        imageView?.sizeThatFits(size.imageSize)

        if needsOutterBorder {
            addOutterImageBorder()
        } else {
            addInnerImageBorder()
        }
    }

    private func addInnerImageBorder() {
        imageView?.layer.cornerRadius = imageView!.frame.height / 2
        imageView?.layer.borderWidth = size.imageBorderWidth
        imageView?.layer.borderColor = config.style.imageBorderColor.cgColor
    }

    private func addOutterImageBorder() {
        imageBorder.frame.size = CGSize(
            width: imageView!.frame.width + 2 * size.imageBorderWidth,
            height: imageView!.frame.height + 2 * size.imageBorderWidth
        )
        imageBorder.center = imageView!.center
        imageBorder.layer.cornerRadius = imageBorder.frame.height / 2
    }
}
