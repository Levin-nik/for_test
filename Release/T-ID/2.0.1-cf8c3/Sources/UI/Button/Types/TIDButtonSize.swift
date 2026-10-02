//
//  TIDButtonSize.swift
//  TID
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

/// Размер кнопки входа
public enum TIDButtonSize {
    /// Размер от 30 до 40, по дефолту 30
    case small
    /// Размер от 40 до 60, по дефолту 40
    case medium
    /// Размер от 60, по дефолту 60
    case large

    init(height: CGFloat) {
        if height < 40 {
            self = .small
        } else if height < 60 {
            self = .medium
        } else {
            self = .large
        }
    }
}

// MARK: - Button settings

extension TIDButtonSize {

    /// Высота кнопки
    var height: CGFloat {
        switch self {
        case .small:
            return 30
        case .medium:
            return 40
        case .large:
            return 60
        }
    }

    /// Минимальные отступы для контента кнопки
    var contentInsets: UIEdgeInsets {
        switch self {
        case .small:
            return .init(top: 7, left: 18, bottom: 7, right: 18)
        case .medium:
            return .init(top: 9, left: 28, bottom: 9, right: 28)
        case .large:
            return .init(top: 16, left: 32, bottom: 16, right: 32)
        }
    }

    /// Размер рамки кнопки
    var buttonBorderSize: CGFloat { 1 }
}

// MARK: - Fonts settings

extension TIDButtonSize {

    /// Шрифт
    var titleFontSize: CGFloat {
        switch self {
        case .small:
            return 10
        case .medium:
            return 14
        case .large:
            return 18
        }
    }

    var badgeFontSize: CGFloat {
        switch self {
        case .small:
            return 9
        case .medium:
            return 13
        case .large:
            return 15
        }
    }
}

// MARK: - Image settings

extension TIDButtonSize {

    /// Отступ между текстом и лого (с бейджем)
    var imageWithBadgeLeadingOffset: CGFloat {
        switch self {
        case .small:
            return 7
        case .medium:
            return 11
        case .large:
            return 13
        }
    }

    /// Отступ между текстом и лого (без бейджа)
    var imageLeadingOffset: CGFloat {
        switch self {
        case .small:
            return 5
        case .medium:
            return 7
        case .large:
            return 9
        }
    }

    /// Изображение
    var image: UIImage? {
        switch self {
        case .small:
            return Bundle.resourcesBundle?
                .imageNamed("idLogoS")
        case .medium:
            return Bundle.resourcesBundle?
                .imageNamed("idLogoM")
        case .large:
            return Bundle.resourcesBundle?
                .imageNamed("idLogoL")
        }
    }

    /// Размер картинки
    var imageSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 27, height: 14)
        case .medium:
            return CGSize(width: 37, height: 20)
        case .large:
            return CGSize(width: 47, height: 25)
        }
    }

    /// Ширина окантовки лого
    var imageBorderWidth: CGFloat {
        switch self {
        case .small:
            return 1
        case .medium, .large:
            return 2
        }
    }
}

// MARK: - Badge settings

extension TIDButtonSize {

    /// Отступы внутри кэшбэка
    var badgeInsets: UIEdgeInsets {
        switch self {
        case .small:
            return .init(top: 2, left: 0, bottom: 2, right: 6)
        case .medium:
            return .init(top: 4, left: 0, bottom: 4, right: 7)
        case .large:
            return .init(top: 5, left: 0, bottom: 5, right: 8)
        }
    }

    /// Отступы вокруг лого
    var badgeLogoOffset: CGFloat {
        switch self {
        case .small:
            return 2
        case .medium:
            return 4
        case .large:
            return 4
        }
    }
}
