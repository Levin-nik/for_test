//
//  TAuthError.swift
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

import Foundation

/// Ошибка авторизации
public enum TAuthError: Error, Equatable, Hashable {
    /// Не удалось запустить приложение по какой-либо причине
    case failedToLaunchApp
    /// Не удалось запустить web сессию по какой-либо причине
    case failedToLaunchWebSession
    /// Пользователь отменил процесс авторизации
    case cancelledByUser
    /// Авторизация сторонних приложений недоступна пользователю Т-Банк
    case unavailable
    /// Не удалось завершить авторизацию после возврата из приложения
    case failedToObtainToken
    /// Не удалось обновить токены
    case failedToRefreshCredentials
    /// Передан невалидный номер телефона
    case invalidPhone
    /// Передан невалидный контекст для презентации web сессии
    case invalidPresentationContext
    /// Авторизация в web сессии не удалась
    case authWebSessionFailed(AnyEquatableError)
    /// Передан невалидный URL для web сессии
    case invalidWebSessionAuthURL
    /// Передан невалидный callbackURL для web сессии
    case invalidWebSessionCallbackURL
    /// Отсутствует URL для получения токена
    case missingAuthCodeURL
}
