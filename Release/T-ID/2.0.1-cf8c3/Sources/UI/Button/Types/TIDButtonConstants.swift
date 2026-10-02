//
//  TIDButtonConstants.swift
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

/// Параметры по умолчанию
public enum TIDButtonConstants {

    /// Титул
    public static let defaultTitle = "T-Bank"

    /// Радиус
    public static let defaultCornerRadius: CGFloat = 8

    /// Стиль
    public static let defaultColorStyle: TIDButtonColorStyle = .primary

    /// Шрифт титула
    public static let defaultTitleFont: UIFont = .systemFont(ofSize: TIDButtonSize.medium.titleFontSize)

    /// Шрифт бейджа
    public static let defaultBadgeFont: UIFont = .systemFont(ofSize: TIDButtonSize.medium.badgeFontSize)
}
