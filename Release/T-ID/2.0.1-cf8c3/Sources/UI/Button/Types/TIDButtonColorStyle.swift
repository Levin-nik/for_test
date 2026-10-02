//
//  TIDButtonColorStyle+Extension.swift
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

/// Цветовой стиль кнопки входа
public enum TIDButtonColorStyle {
    /// Стандартная тема
    case primary
    /// Альтернативная светлая тема
    case alternativeLight
    /// Темная тема
    case dark
    /// Светлая тема
    case light
}

extension TIDButtonColorStyle {

    /// Возвращает цвет фона для соответствующего состояния
    /// - Parameter state: Состояние кнопки
    func backgroundColorFor(state: UIControl.State) -> UIColor {
        switch state {
        case .highlighted:
            return highlightedBackgroundColor
        default:
            return backgroundColor
        }
    }

    /// Цвет текста для соответствующего состояния
    var titleColor: UIColor {
        switch self {
        case .primary, .alternativeLight, .light:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    /// Цвет рамки кнопки
    var borderColor: UIColor {
        switch self {
        case .primary, .alternativeLight, .dark:
            return .clear
        case .light:
            return UIColor(red: 221 / 255, green: 223 / 255, blue: 224 / 255, alpha: 1)
        }
    }

    /// Цвет рамки иконки
    var imageBorderColor: UIColor {
        switch self {
        case .primary, .alternativeLight, .light:
            return .clear
        case .dark:
            return .white
        }
    }

    /// Цвет поля кэшбэка
    var badgeBackgroundColor: UIColor {
        switch self {
        case .primary:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.48)
        case .alternativeLight:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.12)
        case .light:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)
        }
    }

    /// Цвет текста кэшбэка
    var badgeTextColor: UIColor {
        switch self {
        case .primary, .alternativeLight, .light:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

private extension TIDButtonColorStyle {

    private var highlightedBackgroundColor: UIColor {
        switch self {
        case .primary:
            return UIColor(red: 250 / 255, green: 182 / 255, blue: 25 / 255, alpha: 1)
        case .alternativeLight:
            return UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1)
        case .dark:
            return UIColor(red: 64 / 255, green: 64 / 255, blue: 64 / 255, alpha: 1)
        case .light:
            return UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1)
        }
    }

    private var backgroundColor: UIColor {
        switch self {
        case .primary:
            return UIColor(red: 1, green: 221 / 255, blue: 45 / 255, alpha: 1)
        case .alternativeLight:
            return UIColor(red: 245 / 255, green: 245 / 255, blue: 246 / 255, alpha: 1)
        case .dark:
            return UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
        case .light:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
