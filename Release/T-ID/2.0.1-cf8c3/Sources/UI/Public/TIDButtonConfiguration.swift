//
//  TIDButtonConfiguration.swift
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

/// Формат текста в бейдже
public enum BadgeStyle {
    /// Формат: "x% кэшбэк"
    case empty(value: CGFloat)
    /// Формат: "до x% кэшбэка"
    case until(value: CGFloat)
}

/// Конфигурация кнопки
public struct TIDButtonConfiguration {

    /// Стиль кнопки
    let style: TIDButtonColorStyle
    /// Размер
    let size: TIDButtonSize
    /// Радиус скругления кнопки
    let cornerRadius: CGFloat
    /// Шрифт текста на кнопке
    let font: UIFont

    /// Инициализация
    public init(
        style: TIDButtonColorStyle = TIDButtonConstants.defaultColorStyle,
        size: TIDButtonSize = .medium,
        cornerRadius: CGFloat? = nil,
        font: UIFont? = nil
    ) {
        self.style = style
        self.size = size
        self.cornerRadius = cornerRadius ?? TIDButtonConstants.defaultCornerRadius
        self.font = font ?? TIDButtonConstants.defaultTitleFont
    }
}
