//
//  ITID.swift
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

/// Замыкание, вызываемое при успшном входе
///
/// - Parameters:
///   - TTokenPayload: Успешный результат с данными авторизации
///   - TAuthError: Ошибка авторизации
public typealias SignInCompletion = (Result<TTokenPayload, TAuthError>) -> Void

/// Замыкание, вызываемое при успешном выходе
public typealias SignOutCompletion = (Result<Void, Error>) -> Void

/// Объект, инициирующий процедуру входа с помощью Т-Банк
public protocol ITAuthInitiator {
    /// Возвращает `true` если есть возможность авторизоваться в приложении
    /// Если флаг `false`, то вызов `startTAuth` приведет к открытию WevView или ошибке,
    /// если вход через WevView не был настроен
    var isTAuthAvailable: Bool { get }

    /// Инициирует вход
    /// - Parameter completion: Блок с авторизационными данными или ошибкой. Всегда вызывается на главном потоке
    func startTAuth(_ completion: @escaping SignInCompletion)

    /// Инициирует вход
    /// - Parameter phone: Телефон пользователя. Формат +79995553344
    /// - Parameter completion: Блок с авторизационными данными или ошибкой. Всегда вызывается на главном потоке
    func startTAuth(phone: String?, _ completion: @escaping SignInCompletion)
}

/// Расширение ITAuthInitiator
public extension ITAuthInitiator {

    /// Инициирует вход
    /// - Parameter phone: Телефон пользователя. Формат +79995553344
    /// - Parameter completion: Блок с авторизационными данными или ошибкой. Всегда вызывается на главном потоке
    func startTAuth(phone: String?, _ completion: @escaping SignInCompletion) {
        startTAuth(completion)
    }
}

/// Объект, продолжающий процесс входа после возврата в текущее приложение из приложения Т-Банк
public protocol ITAuthCallbackHandler {
    /// Пытается продолжить процесс входа с помощью URL, по которому был осуществлен возврат  в текущее приложение
    func handleCallbackUrl(_ url: URL) -> Bool
}

/// Объект, позволяющий обновить авторизационные данные
public protocol ITCredentialsRefresher {

    /// Обновляет авторизационные данные
    /// - Parameters:
    ///   - refreshToken: `Refresh token`, полученный с обновляемыми авторизационными данными
    ///   - completion: Блок с обновленными авторизационными данными или ошибкой. Всегда вызывается на главном потоке
    func obtainTokenPayload(
        using refreshToken: String,
        _ completion: @escaping (Result<TTokenPayload, TAuthError>) -> Void
    )
}

/// Объект, инициирующий отзыв авторизации по `access` или `refresh` токену
public protocol ITSignOutInitiator {

    /// Отзывает авторизацию по заданному токену
    /// - Parameters:
    ///   - token: Токен
    ///   - tokenTypeHint: Тип токена
    ///   - completion: Коллбек, который может содержать ошибку или ничего если ошибки не произошло. Всегда вызывается на главном потоке
    func signOut(with token: String, tokenTypeHint: SignOutTokenTypeHint, completion: @escaping SignOutCompletion)
}

/// Определяет флоу запуска сдк
public enum TMode {
    /// Режим white label
    case whiteLabel
    /// Режим partner (стандартный)
    case partner
}

public protocol ITID: ITAuthInitiator, ITAuthCallbackHandler, ITCredentialsRefresher, ITSignOutInitiator {}
