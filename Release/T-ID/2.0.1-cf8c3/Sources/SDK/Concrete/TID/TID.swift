//
//  TID.swift
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

final class TID: ITID {

    // MARK: - Dependencies

    let payloadGenerator: IPKCEPayloadGenerator
    let appLauncher: IAppLauncher
    let callbackUrlParser: ICallbackURLParser
    let api: IAPI
    let authWebSessionBuilder: IAuthWebSessionBuilder
    let webSessionSourceProvider: IAuthWebSessionSourceProvider?
    let phoneValidator: TPhoneValidator?
    let versionProvider: IVersionProvider
    let universalLinksOnly: Bool
    let mode: TMode

    // MARK: - State

    private var currentProcess: AuthProcess?
    private var authWebSession: IAuthWebSession?

    // MARK: - Properties

    let clientId: String
    let callbackUrl: String

    init(
        payloadGenerator: IPKCEPayloadGenerator,
        appLauncher: IAppLauncher,
        callbackUrlParser: ICallbackURLParser,
        api: IAPI,
        authWebSessionBuilder: IAuthWebSessionBuilder,
        webSessionSourceProvider: IAuthWebSessionSourceProvider?,
        phoneValidator: TPhoneValidator?,
        versionProvider: IVersionProvider,
        clientId: String,
        callbackUrl: String,
        universalLinksOnly: Bool,
        mode: TMode
    ) {
        self.payloadGenerator = payloadGenerator
        self.appLauncher = appLauncher
        self.callbackUrlParser = callbackUrlParser
        self.api = api
        self.authWebSessionBuilder = authWebSessionBuilder
        self.webSessionSourceProvider = webSessionSourceProvider
        self.phoneValidator = phoneValidator
        self.versionProvider = versionProvider
        self.clientId = clientId
        self.callbackUrl = callbackUrl
        self.universalLinksOnly = universalLinksOnly
        self.mode = mode
    }

    // MARK: - ITAuthInitiator

    var isTAuthAvailable: Bool {
        appLauncher.canLaunchApp
    }

    /// Запустить авторизацию, не поддерживает сценарий WL
    /// - Parameter completion: замыкание с результатом прохождения авторизации
    func startTAuth(_ completion: @escaping SignInCompletion) {
        do {
            let payload = try payloadGenerator.generatePayload()
            let options = AppLaunchOptions(
                clientId: clientId,
                callbackUrl: callbackUrl,
                payload: payload,
                phone: nil,
                sdkVersion: versionProvider.componentVersion
            )
            try authThroughApp(with: options, completion: completion)

            let process = AuthProcess(
                appLaunchOptions: options,
                completion: completion
            )
            currentProcess = process
        } catch {
            completion(.failure(.failedToLaunchApp))
        }
    }

    /// Запустить авторизацию с передачей номера телефона
    /// - Parameter phone: телефон пользователя
    /// - Parameter completion: замыкание с результатом прохождения авторизации
    func startTAuth(phone: String?, _ completion: @escaping SignInCompletion) {
        do {
            let payload = try payloadGenerator.generatePayload()
            let options: AppLaunchOptions

            switch mode {
            case .whiteLabel:
                try phoneValidator?.verify(phone: phone)
                options = AppLaunchOptions(
                    clientId: clientId,
                    callbackUrl: callbackUrl,
                    payload: payload,
                    phone: phone,
                    sdkVersion: versionProvider.componentVersion
                )
                authThroughWebView(with: options, completion: completion)

            case .partner:
                options = AppLaunchOptions(
                    clientId: clientId,
                    callbackUrl: callbackUrl,
                    payload: payload,
                    phone: nil,
                    sdkVersion: versionProvider.componentVersion
                )
                try authThroughApp(with: options, completion: completion)
            }

            let process = AuthProcess(
                appLaunchOptions: options,
                completion: completion
            )
            currentProcess = process
        } catch TAuthError.invalidPhone {
            completion(.failure(.invalidPhone))
        } catch {
            completion(.failure(.failedToLaunchApp))
        }
    }

    func openWebSession(
        options: AppLaunchOptions,
        completion: @escaping SignInCompletion
    ) {
        guard let sourceViewController = try? webSessionSourceProvider?.getSourceViewController() else {
            completion(.failure(.invalidPresentationContext))
            return
        }

        authWebSession = authWebSessionBuilder.build(with: options)
        authWebSession?.start(from: sourceViewController) { [weak self] result in
            switch result {
            case let .success(url):
                _ = self?.handleCallbackUrl(url)
            case let .failure(error):
                completion(.failure(error))
                self?.authWebSession?.cancel()
                self?.authWebSession = nil
            }
        }
    }

    // MARK: - ITAuthCallbackHandler

    func handleCallbackUrl(_ url: URL) -> Bool {
        guard
            url.absoluteString.hasPrefix(callbackUrl),
            let process = currentProcess,
            let result = callbackUrlParser.parse(url)
        else { return false }

        switch result {
        case .cancelled, .unknownError:
            finish(process, with: .failure(.cancelledByUser))
        case .unavailable:
            finish(process, with: .failure(.unavailable))
        case let .codeObtained(code):
            processCode(code, for: process)
        }

        return true
    }

    // MARK: - ITCredentialsRefresher

    func obtainTokenPayload(
        using refreshToken: String,
        _ completion: @escaping (Result<TTokenPayload, TAuthError>) -> Void
    ) {
        api.obtainCredentials(with: refreshToken, clientId: clientId) { result in
            completion(result.mapError { _ in TAuthError.failedToRefreshCredentials })
        }
    }

    // MARK: - ITSignOutInitiator

    func signOut(with token: String, tokenTypeHint: SignOutTokenTypeHint, completion: @escaping SignOutCompletion) {
        signOut(with: token, tokenTypeHint, completion)
    }

    // MARK: - Private

    private func processCode(_ code: String, for process: AuthProcess) {
        api.obtainCredentials(
            with: code,
            clientId: process.appLaunchOptions.clientId,
            codeVerifier: process.appLaunchOptions.payload.verifier,
            redirectUri: process.appLaunchOptions.callbackUrl
        ) { [weak self] result in
            let mappedResult = result.mapError { _ in
                TAuthError.failedToObtainToken
            }

            self?.finish(process, with: mappedResult)
        }
    }

    private func finish(_ process: AuthProcess, with result: Result<TTokenPayload, TAuthError>) {
        if let authWebSession {
            authWebSession.cancel()
            self.authWebSession = nil
        }

        process.completion(result)
    }

    private func signOut(with token: String, _ tokenTypeHint: SignOutTokenTypeHint, _ completion: @escaping SignOutCompletion) {
        api.signOut(with: token, tokenTypeHint: tokenTypeHint, clientId: clientId) { result in
            completion(result.map { _ in {}() })
        }
    }

    private func authThroughApp(with options: AppLaunchOptions, completion: @escaping SignInCompletion) throws {
        try appLauncher.launchApp(
            with: options,
            universalLinksOnly: universalLinksOnly,
            completion: { [weak self] didLaunchMobileApp in
                guard let self = self else { return }

                guard !didLaunchMobileApp else { return }

                self.authThroughWebView(with: options, completion: completion)
            }
        )
    }

    private func authThroughWebView(with options: AppLaunchOptions, completion: @escaping SignInCompletion) {
        guard universalLinksOnly,
              webSessionSourceProvider != nil else {
            return completion(.failure(.failedToLaunchApp))
        }

        openWebSession(
            options: options,
            completion: completion
        )
    }
}
