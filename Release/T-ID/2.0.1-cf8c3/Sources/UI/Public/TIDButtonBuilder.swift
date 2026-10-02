//
//  TIDButtonBuilder.swift
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

/// Сборщик кнопки входа через Т-Банк
public enum TIDButtonBuilder {

    /// Создает прямоугольную кнопку входа через Т-Банк
    /// - Parameter configuration: Конфигурация кнопки
    /// - Parameter title: Текст кнопки
    /// - Parameter badge: Конфигурация бейджа
    /// - Returns: Контрол кнопки
    public static func build(
        configuration: TIDButtonConfiguration = TIDButtonConfiguration(),
        title: String? = nil
    ) -> UIControl {
        TIDButton(
            configuration: configuration,
            titleString: title,
            badgeStyle: nil
        )
    }

    /// Создает круглую кнопку входа через Т-Банк
    /// - Parameter colorStyle: Цветовая тема кнопки
    /// - Returns: Контрол кнопки
    public static func buildCompact(colorStyle: TIDButtonColorStyle = .primary) -> UIControl {
        TIDCompactButton(colorStyle: colorStyle)
    }
}
