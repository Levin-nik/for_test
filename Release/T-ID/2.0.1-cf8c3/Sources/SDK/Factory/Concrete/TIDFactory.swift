//
//  TIDFactory.swift
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
import UIKit

/// Реализация фабрики `ITID` по умолчанию
public final class TIDFactory: ITIDFactory {

    // Dependencies
    private let clientId: String
    private let callbackUrl: String
    private let mode: TMode
    private let appConfiguration: TargetAppConfiguration
    private let environmentConfiguration: EnvironmentConfiguration
    private let webSessionSourceProvider: IAuthWebSessionSourceProvider?

    // MARK: - Initialization

    /// Создаёт новый экземпляр класса
    ///
    /// - Parameters:
    ///   - clientId: Идентификатор приложения
    ///   - callbackUrl: Ссылка обратного вызова, по которой можно вернуться обратно в приложение
    ///   - mode: Определяет режим флоу запуска сдк
    ///   - app: Приложение Т-Банк, использующееся для входа
    ///   - environment: Окружение Т-Банк
    public convenience init(
        clientId: String,
        callbackUrl: String,
        mode: TMode = .partner,
        app: TApp = .bank,
        environment: TEnvironment = .production,
        webSessionSourceProvider: IAuthWebSessionSourceProvider? = DefaultAuthWebSessionSourceProvider.instance
    ) {
        self.init(
            clientId: clientId,
            callbackUrl: callbackUrl,
            mode: mode,
            appConfiguration: app,
            environmentConfiguration: environment,
            webSessionSourceProvider: webSessionSourceProvider
        )
    }

    /// Создаёт новый экземпляр класса
    ///
    /// - Parameters:
    ///   - clientId: Идентификатор приложения
    ///   - callbackUrl: Ссылка обратного вызова, по которой можно вернуться обратно в приложение
    ///   - mode: Определяет режим флоу запуска сдк
    ///   - appConfiguration: Конфигурация приложения, используемого для авторизации
    ///   - environmentConfiguration: Конфигурация окружения для работы SDK
    public init(
        clientId: String,
        callbackUrl: String,
        mode: TMode,
        appConfiguration: TargetAppConfiguration,
        environmentConfiguration: EnvironmentConfiguration,
        webSessionSourceProvider: IAuthWebSessionSourceProvider? = DefaultAuthWebSessionSourceProvider.instance
    ) {
        self.clientId = clientId
        self.callbackUrl = callbackUrl
        self.mode = mode
        self.environmentConfiguration = environmentConfiguration
        self.appConfiguration = appConfiguration
        self.webSessionSourceProvider = webSessionSourceProvider
    }

    // MARK: - ITIDFactory

    public func build() -> ITID {
        let urlSchemeBuilder = URLSchemeBuilder(authDomains: appConfiguration.authDomains)
        let appLauncher = URLSchemeAppLauncher(
            appUrlScheme: appConfiguration.urlScheme,
            builder: urlSchemeBuilder,
            router: UIApplication.shared
        )

        let pinningDelegate = PinningDelegate(hostAndPinsURL: environmentConfiguration.hostAndPinsUrl)
        let urlSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: pinningDelegate,
            delegateQueue: nil
        )
        let requestBuilder = RequestBuilder(baseUrl: environmentConfiguration.apiBaseUrl)
        let api = API(
            requestBuilder: requestBuilder,
            requestProcessor: urlSession,
            responseDispatcher: DispatchQueue.main
        )

        let codeVerifierGenerator = RFC7636PKCECodeVerifierGenerator()
        let codeChallengeDerivator = RFC7636PKCECodeChallengeDerivator()

        let payloadGenerator = PKCEPayloadGenerator(
            codeVerifierGenerator: codeVerifierGenerator,
            codeChallengeDerivator: codeChallengeDerivator
        )

        let callbackUrlParser = CallbackURLParser()

        let authWebSessionBuilder = AuthWebSessionBuilder(baseUrl: environmentConfiguration.apiBaseUrl)

        let phoneValidator: TPhoneValidator?
        switch mode {
        case .whiteLabel:
            phoneValidator = TPhoneValidator()
        case .partner:
            phoneValidator = nil
        }

        return TID(
            payloadGenerator: payloadGenerator,
            appLauncher: appLauncher,
            callbackUrlParser: callbackUrlParser,
            api: api,
            authWebSessionBuilder: authWebSessionBuilder,
            webSessionSourceProvider: webSessionSourceProvider,
            phoneValidator: phoneValidator,
            versionProvider: Bundle.resourcesBundle ?? Bundle.defaultBundle,
            clientId: clientId,
            callbackUrl: callbackUrl,
            universalLinksOnly: appConfiguration.usesUniversalLinks,
            mode: mode
        )
    }
}
